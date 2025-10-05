/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "PX4SprayingComponent.h"
#include "ParameterManager.h"
#include "Vehicle.h"

PX4SprayingComponent::PX4SprayingComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, AutoPilotPlugin::UnknownVehicleComponent, parent)
    , _name(tr("Spraying"))
{
}

QString PX4SprayingComponent::name(void) const
{
    return _name;
}

QString PX4SprayingComponent::description(void) const
{
    return tr("Spraying Setup is used to configure spraying system parameters.");
}

QString PX4SprayingComponent::iconResource(void) const
{
    return "/qmlimages/SprayingIcon.svg";
}

bool PX4SprayingComponent::requiresSetup(void) const
{
    return false;
}

bool PX4SprayingComponent::setupComplete(void) const
{
    return true;
}

QStringList PX4SprayingComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl PX4SprayingComponent::setupSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/PX4SprayingComponent.qml");
}

QUrl PX4SprayingComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/PX4SprayingComponentSummary.qml");
}

