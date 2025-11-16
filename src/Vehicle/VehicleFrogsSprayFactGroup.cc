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

void VehicleFrogsSprayFactGroup::handleMessage(Vehicle* vehicle, mavlink_message_t& message)
{
    Q_UNUSED(vehicle);

    switch (message.msgid) {
    case 5431:  // FROGS_SPRAY message ID
        _handleFrogsSpray(message);
        break;
    default:
        break;
    }
}

void VehicleFrogsSprayFactGroup::_handleFrogsSpray(mavlink_message_t& message)
{
    // Manual decoding of FROGS_SPRAY message (ID 5431)
    // Message structure: uint64_t timestamp (offset 0), float vol_water (offset 8), 
    //                    double flow_rate (offset 12), double c_actuator (offset 20)
    // Total size: 8 + 4 + 8 + 8 = 28 bytes
    
    if (message.len < 28) {
        qWarning() << "FROGS_SPRAY message too short:" << message.len << "expected 28";
        return;
    }
    
    // Use payload array for safe byte-by-byte access (MAVLink payload is uint8_t array)
    // Note: We need to handle alignment properly for doubles
    uint64_t timestamp_val;
    float vol_water;
    double flow_rate;
    double c_actuator;
    
    // Decode timestamp (uint64_t at offset 0)
    memcpy(&timestamp_val, &message.payload[0], sizeof(uint64_t));
    
    // Decode vol_water (float at offset 8)
    memcpy(&vol_water, &message.payload[8], sizeof(float));
    
    // Decode flow_rate (double at offset 12) - may need alignment
    memcpy(&flow_rate, &message.payload[12], sizeof(double));
    
    // Decode c_actuator (double at offset 20)
    memcpy(&c_actuator, &message.payload[20], sizeof(double));
    
    // Set values
    timestamp()->setRawValue(QVariant(static_cast<qulonglong>(timestamp_val)));
    volWater()->setRawValue(vol_water);
    flowRate()->setRawValue(flow_rate);
    cActuator()->setRawValue(c_actuator);

    _setTelemetryAvailable(true);
}