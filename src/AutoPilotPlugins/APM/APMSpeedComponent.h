

/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include "VehicleComponent.h"

class APMSpeedComponent : public VehicleComponent
{
    Q_OBJECT

public:
    explicit APMSpeedComponent(Vehicle *vehicle, AutoPilotPlugin *autopilot, QObject *parent = nullptr);

    QStringList setupCompleteChangedTriggerList() const final;

    QString name() const final { return _name; }
    QString description() const final;
    QString iconResource() const final { return QStringLiteral("/qmlimages/Quad.svg"); }
    bool requiresSetup() const final { return false; }
    bool setupComplete() const final { return true; }
    QUrl setupSource() const final;
    QUrl summaryQmlSource() const final;
    bool allowSetupWhileArmed() const final { return true; }
    bool allowSetupWhileFlying() const final { return true; }

private:
    const QString _name = tr("Speed");
};
