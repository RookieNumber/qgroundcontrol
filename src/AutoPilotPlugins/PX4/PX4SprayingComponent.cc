/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "PX4SprayingComponent.h"
#include "PX4AutoPilotPlugin.h"
#include "ParameterManager.h"

PX4SprayingComponent::PX4SprayingComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent)
    , _name(tr("Spraying"))
{
}

QString PX4SprayingComponent::name(void) const
{
    return _name;
}

QString PX4SprayingComponent::description(void) const
{
    return tr("Spraying system configuration for flow rate control and tank level monitoring.");
}

QString PX4SprayingComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/SprayingIcon.svg");
}

bool PX4SprayingComponent::requiresSetup(void) const
{
    return true;
}

QUrl PX4SprayingComponent::setupSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/PX4SprayingComponent.qml"));
}

QUrl PX4SprayingComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/PX4SprayingComponentSummary.qml"));
}

QStringList PX4SprayingComponent::setupCompleteChangedTriggerList(void) const
{
    QStringList triggers;
    // These are APM-style params; for PX4 we only trigger on presence if available
    triggers << QStringLiteral("SPRAY_ENABLE");
    triggers << QStringLiteral("SPRAY_TANK_CAPACITY");
    triggers << QStringLiteral("SPRAY_FLOW_RATE");
    triggers << QStringLiteral("SPRAY_FLOW_MONITOR");
    return triggers;
}

bool PX4SprayingComponent::setupComplete(void) const
{
    // If parameters are not present, consider setup complete so the UI doesn't block other setup
    if (!_vehicle->parameterManager()->parameterExists(FactSystem::defaultComponentId, "SPRAY_ENABLE")) {
        return true;
    }
    return true;
}


