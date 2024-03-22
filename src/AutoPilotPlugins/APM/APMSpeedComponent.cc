
/// @file
///     @author Wildan Fadillah <wildanfadillah8@gmail.com>

#include "APMSpeedComponent.h"
#include "APMAutoPilotPlugin.h"
#include "APMAirframeComponent.h"

APMSpeedComponent::APMSpeedComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent)
    , _name(tr("Kontrol Kecepatan"))
{
}

QString APMSpeedComponent::name(void) const
{
    return _name;
}

QString APMSpeedComponent::description(void) const
{
    switch (_vehicle->vehicleType()) {
    case MAV_TYPE_SUBMARINE:
        return tr("Halaman ini menyediakan fungsi untuk mengontrol kecepatan pengoperasian pada drone.");
        break;
    case MAV_TYPE_GROUND_ROVER:
    case MAV_TYPE_FIXED_WING:
    case MAV_TYPE_QUADROTOR:
    case MAV_TYPE_COAXIAL:
    case MAV_TYPE_HELICOPTER:
    case MAV_TYPE_HEXAROTOR:
    case MAV_TYPE_OCTOROTOR:
    case MAV_TYPE_TRICOPTER:
    default:
        return tr("Halaman ini menyediakan fungsi untuk mengontrol kecepatan pengoperasian pada drone.");
        break;
    }
}

QString APMSpeedComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/Quad.svg");
}

bool APMSpeedComponent::requiresSetup(void) const
{
    return false;
}

bool APMSpeedComponent::setupComplete(void) const
{
    // FIXME: What aboout invalid settings?
    return true;
}

QStringList APMSpeedComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl APMSpeedComponent::setupSource(void) const
{
    QString qmlFile;

    switch (_vehicle->vehicleType()) {
    case MAV_TYPE_FIXED_WING:
    case MAV_TYPE_QUADROTOR:
    case MAV_TYPE_COAXIAL:
    case MAV_TYPE_HELICOPTER:
    case MAV_TYPE_HEXAROTOR:
    case MAV_TYPE_OCTOROTOR:
    case MAV_TYPE_TRICOPTER:
    case MAV_TYPE_GROUND_ROVER:
        qmlFile = QStringLiteral("qrc:/qml/APMSpeedComponent.qml");
        break;
    default:
        qmlFile = QStringLiteral("qrc:/qml/APMNotSupported.qml");
        break;
    }

    return QUrl::fromUserInput(qmlFile);
}

QUrl APMSpeedComponent::summaryQmlSource(void) const
{
    QString qmlFile;

    switch (_vehicle->vehicleType()) {
    case MAV_TYPE_FIXED_WING:
    case MAV_TYPE_QUADROTOR:
    case MAV_TYPE_COAXIAL:
    case MAV_TYPE_HELICOPTER:
    case MAV_TYPE_HEXAROTOR:
    case MAV_TYPE_OCTOROTOR:
    case MAV_TYPE_TRICOPTER:
    case MAV_TYPE_GROUND_ROVER:
        qmlFile = QStringLiteral("qrc:/qml/APMSpeedComponentSummary.qml");
        break;
    default:
        qmlFile = QStringLiteral("qrc:/qml/APMNotSupported.qml");
        break;
    }

    return QUrl::fromUserInput(qmlFile);
}
