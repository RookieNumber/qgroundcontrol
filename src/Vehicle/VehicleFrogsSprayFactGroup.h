#pragma once

#include "FactGroup.h"

class VehicleFrogsSprayFactGroup : public FactGroup
{
    Q_OBJECT
    Q_PROPERTY(Fact *timestamp      READ timestamp      CONSTANT)
    Q_PROPERTY(Fact *volWater       READ volWater       CONSTANT)
    Q_PROPERTY(Fact *flowRate       READ flowRate       CONSTANT)
    Q_PROPERTY(Fact *cActuator      READ cActuator      CONSTANT)

public:
    explicit VehicleFrogsSprayFactGroup(QObject *parent = nullptr);

    Fact *timestamp() { return &_timestampFact; }
    Fact *volWater() { return &_volWaterFact; }
    Fact *flowRate() { return &_flowRateFact; }
    Fact *cActuator() { return &_cActuatorFact; }

    // Overrides from FactGroup
    void handleMessage(Vehicle* vehicle, mavlink_message_t& message) override;

private:
    void _handleFrogsSpray(mavlink_message_t& message);

    Fact _timestampFact = Fact(0, QStringLiteral("timestamp"), FactMetaData::valueTypeUint64);
    Fact _volWaterFact = Fact(0, QStringLiteral("volWater"), FactMetaData::valueTypeFloat);
    Fact _flowRateFact = Fact(0, QStringLiteral("flowRate"), FactMetaData::valueTypeDouble);
    Fact _cActuatorFact = Fact(0, QStringLiteral("cActuator"), FactMetaData::valueTypeDouble);
};