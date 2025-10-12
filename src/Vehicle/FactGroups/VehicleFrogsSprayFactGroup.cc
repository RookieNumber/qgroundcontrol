#include "VehicleFrogsSprayFactGroup.h"
#include "Vehicle.h"

VehicleFrogsSprayFactGroup::VehicleFrogsSprayFactGroup(QObject *parent)
    : FactGroup(1000, QStringLiteral(":/json/Vehicle/FrogsSprayFact.json"), parent)
{
    _addFact(&_sprayRateFact);
    _addFact(&_tankLevelFact);
    _addFact(&_sprayStatusFact);
    _addFact(&_totalSprayedFact);

    _sprayRateFact.setRawValue(qQNaN());
    _tankLevelFact.setRawValue(qQNaN());
    _sprayStatusFact.setRawValue(0);
    _totalSprayedFact.setRawValue(qQNaN());
}

void VehicleFrogsSprayFactGroup::handleMessage(Vehicle *vehicle, const mavlink_message_t &message)
{
    Q_UNUSED(vehicle);

    switch (message.msgid) {
    case MAVLINK_MSG_ID_FROGS_SPRAY:  // Message ID 500
        _handleFrogsSpray(message);
        break;
    default:
        break;
    }
}

void VehicleFrogsSprayFactGroup::_handleFrogsSpray(const mavlink_message_t &message)
{
    mavlink_frogs_spray_t frogsSpray{};
    mavlink_msg_frogs_spray_decode(&message, &frogsSpray);

    // Basic validation and set values
    if (!qIsNaN(frogsSpray.spray_rate)) {
        sprayRate()->setRawValue(frogsSpray.spray_rate);
    }
    
    if (!qIsNaN(frogsSpray.tank_level)) {
        tankLevel()->setRawValue(frogsSpray.tank_level);
    }
    
    // Status is always valid (uint8_t)
    sprayStatus()->setRawValue(frogsSpray.spray_status);
    
    if (!qIsNaN(frogsSpray.total_sprayed)) {
        totalSprayed()->setRawValue(frogsSpray.total_sprayed);
    }

    _setTelemetryAvailable(true);
}