/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "APMSpreaderComponent.h"
#include "APMAutoPilotPlugin.h"
#include "ParameterManager.h"

APMSpreaderComponent::APMSpreaderComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent),
    _name(tr("Spreader"))
{
}

QString APMSpreaderComponent::name(void) const
{
    return _name;
}

QString APMSpreaderComponent::description(void) const
{
    return tr("Spreader system configuration for material distribution control and hopper level monitoring.");
}

QString APMSpreaderComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/SpreaderIcon.svg");
}

bool APMSpreaderComponent::requiresSetup(void) const
{
    return true;
}

QUrl APMSpreaderComponent::setupSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMSpreaderComponent.qml"));
}

QUrl APMSpreaderComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMSpreaderComponentSummary.qml"));
}

QStringList APMSpreaderComponent::setupCompleteChangedTriggerList(void) const
{
    QStringList triggers;
    
    // Trigger when spreader parameters change
    triggers << QStringLiteral("SPREAD_ENABLE");
    triggers << QStringLiteral("SPREAD_HOPPER_CAPACITY");
    triggers << QStringLiteral("SPREAD_RATE");
    triggers << QStringLiteral("SPREAD_MONITOR");
    
    return triggers;
}

bool APMSpreaderComponent::setupComplete(void) const
{
    // Always return true to ensure component is always visible
    return true;
}
