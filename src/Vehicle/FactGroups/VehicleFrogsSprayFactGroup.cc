#include "VehicleFrogsSprayFactGroup.h"
#include "Vehicle.h"

VehicleFrogsSprayFactGroup::VehicleFrogsSprayFactGroup(QObject *parent)
    : FactGroup(1000, QStringLiteral(":/json/Vehicle/FrogsSprayFact.json"), parent)
{
    _addFact(&_timestampFact);
    _addFact(&_volWaterFact);
    _addFact(&_flowRateFact);
    _addFact(&_cActuatorFact);

    _timestampFact.setRawValue(0);
    _volWaterFact.setRawValue(qQNaN());
    _flowRateFact.setRawValue(qQNaN());
    _cActuatorFact.setRawValue(qQNaN());
}

void VehicleFrogsSprayFactGroup::handleMessage(Vehicle *vehicle, const mavlink_message_t &message)
{
    Q_UNUSED(vehicle);

    switch (message.msgid) {
    case 500:  // FROGS_SPRAY message ID
        _handleFrogsSpray(message);
        break;
    default:
        break;
    }
}

void VehicleFrogsSprayFactGroup::_handleFrogsSpray(const mavlink_message_t &message)
{
    // Manual decoding of FROGS_SPRAY message (ID 500)
    // Message structure: uint64_t timestamp, float vol_water, double flow_rate, double c_actuator
    
    if (message.len < 28) {  // Expected message length: 8+4+8+8 = 28 bytes
        qWarning() << "FROGS_SPRAY message too short:" << message.len;
        return;
    }
    
    // Decode message payload manually
    uint64_t timestamp_val;
    float vol_water;
    double flow_rate;
    double c_actuator;
    
    // MAVLink payload is 64-bit aligned, so we can access it directly
    memcpy(&timestamp_val, &message.payload64[0], 8);
    memcpy(&vol_water, &message.payload64[1], 4);
    memcpy(&flow_rate, &message.payload64[1] + 4, 8);
    memcpy(&c_actuator, &message.payload64[3], 8);
    
    // Set values
    timestamp()->setRawValue(timestamp_val);
    
    if (!qIsNaN(vol_water)) {
        volWater()->setRawValue(vol_water);
    }
    
    if (!qIsNaN(flow_rate)) {
        flowRate()->setRawValue(flow_rate);
    }
    
    if (!qIsNaN(c_actuator)) {
        cActuator()->setRawValue(c_actuator);
    }

    _setTelemetryAvailable(true);
}