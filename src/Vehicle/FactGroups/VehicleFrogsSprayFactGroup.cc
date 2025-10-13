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
    // Message structure: uint64_t time_usec, float spray_rate, float tank_level, uint8_t spray_status, float total_sprayed
    
    if (message.len < 21) {  // Expected message length: 8+4+4+1+4 = 21 bytes
        qWarning() << "FROGS_SPRAY message too short:" << message.len;
        return;
    }
    
    // Decode message payload manually
    uint64_t time_usec;
    float spray_rate;
    float tank_level;
    uint8_t spray_status;
    float total_sprayed;
    
    memcpy(&time_usec, &message.payload64[0], 8);
    memcpy(&spray_rate, &message.payload64[1], 4);
    memcpy(&tank_level, &message.payload64[1] + 4, 4);
    memcpy(&spray_status, &message.payload64[2], 1);
    memcpy(&total_sprayed, &message.payload64[2] + 1, 4);
    
    // Basic validation and set values
    if (!qIsNaN(spray_rate)) {
        sprayRate()->setRawValue(spray_rate);
    }
    
    if (!qIsNaN(tank_level)) {
        tankLevel()->setRawValue(tank_level);
    }
    
    // Status is always valid (uint8_t)
    sprayStatus()->setRawValue(spray_status);
    
    if (!qIsNaN(total_sprayed)) {
        totalSprayed()->setRawValue(total_sprayed);
    }

    _setTelemetryAvailable(true);
}