#include "VehicleFrogsSprayFactGroup.h"
#include "Vehicle.h"

VehicleFrogsSprayFactGroup::VehicleFrogsSprayFactGroup(QObject *parent)
    : FactGroup(1000, QStringLiteral(":/json/Vehicle/FrogsSprayFact.json"), parent)
{
    _addFact(&_timestampFact, QStringLiteral("timestamp"));
    _addFact(&_volWaterFact, QStringLiteral("volWater"));
    _addFact(&_flowRateFact, QStringLiteral("flowRate"));
    _addFact(&_cActuatorFact, QStringLiteral("cActuator"));

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
    if (message.len < 28) {
        qWarning() << "FROGS_SPRAY message too short:" << message.len << "expected 28";
        return;
    }

    const uint8_t* payload = reinterpret_cast<const uint8_t*>(message.payload64);

    uint64_t timestamp_val;
    float vol_water;
    double flow_rate;
    double c_actuator;

    memcpy(&timestamp_val, &payload[0], sizeof(uint64_t));
    memcpy(&vol_water,  &payload[8], sizeof(float));
    memcpy(&flow_rate,  &payload[12], sizeof(double));
    memcpy(&c_actuator, &payload[20], sizeof(double));

    timestamp()->setRawValue(QVariant(static_cast<qulonglong>(timestamp_val)));
    volWater()->setRawValue(vol_water);
    flowRate()->setRawValue(flow_rate);
    cActuator()->setRawValue(c_actuator);

    _setTelemetryAvailable(true);
}
