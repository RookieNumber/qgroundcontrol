#pragma once

#include "FactGroup.h"

class VehicleFrogsSprayFactGroup : public FactGroup
{
    Q_OBJECT
    Q_PROPERTY(Fact *sprayRate      READ sprayRate      CONSTANT)
    Q_PROPERTY(Fact *tankLevel      READ tankLevel      CONSTANT)
    Q_PROPERTY(Fact *sprayStatus    READ sprayStatus    CONSTANT)
    Q_PROPERTY(Fact *totalSprayed   READ totalSprayed   CONSTANT)

public:
    explicit VehicleFrogsSprayFactGroup(QObject *parent = nullptr);

    Fact *sprayRate() { return &_sprayRateFact; }
    Fact *tankLevel() { return &_tankLevelFact; }
    Fact *sprayStatus() { return &_sprayStatusFact; }
    Fact *totalSprayed() { return &_totalSprayedFact; }

    // Overrides from FactGroup
    void handleMessage(Vehicle *vehicle, const mavlink_message_t &message) final;

private:
    void _handleFrogsSpray(const mavlink_message_t &message);

    Fact _sprayRateFact = Fact(0, QStringLiteral("sprayRate"), FactMetaData::valueTypeDouble);
    Fact _tankLevelFact = Fact(0, QStringLiteral("tankLevel"), FactMetaData::valueTypeDouble);
    Fact _sprayStatusFact = Fact(0, QStringLiteral("sprayStatus"), FactMetaData::valueTypeUint8);
    Fact _totalSprayedFact = Fact(0, QStringLiteral("totalSprayed"), FactMetaData::valueTypeDouble);
};