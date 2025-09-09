/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

 #include "APMSprayingComponent.h"
 #include "APMAutoPilotPlugin.h"
 #include "ParameterManager.h"
 
 APMSprayingComponent::APMSprayingComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
     : VehicleComponent(vehicle, autopilot, parent),
     _name(tr("Spraying"))
 {
 }
 
 QString APMSprayingComponent::name(void) const
 {
     return _name;
 }
 
 QString APMSprayingComponent::description(void) const
 {
     return tr("Spraying system configuration for flow rate control and tank level monitoring.");
 }
 
 QString APMSprayingComponent::iconResource(void) const
 {
     return QStringLiteral("/qmlimages/SprayingIcon.svg");
 }
 
 bool APMSprayingComponent::requiresSetup(void) const
 {
     return true;
 }
 
 QUrl APMSprayingComponent::setupSource(void) const
 {
     return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMSprayingComponent.qml"));
 }
 
 QUrl APMSprayingComponent::summaryQmlSource(void) const
 {
     return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMSprayingComponentSummary.qml"));
 }
 
 QStringList APMSprayingComponent::setupCompleteChangedTriggerList(void) const
 {
     QStringList triggers;
     
     // Trigger when spraying parameters change
     triggers << QStringLiteral("SPRAY_ENABLE");
     triggers << QStringLiteral("SPRAY_TANK_CAPACITY");
     triggers << QStringLiteral("SPRAY_FLOW_RATE");
     triggers << QStringLiteral("SPRAY_FLOW_MONITOR");
     
     return triggers;
 }
 
 bool APMSprayingComponent::setupComplete(void) const
 {


    // if (!_vehicle->parameterManager()->parameterExists(FactSystem::defaultComponentId, "SPRAY_ENABLE")) {
    //     return false;
    // }
    
    // if (!_vehicle->parameterManager()->parameterExists(FactSystem::defaultComponentId, "SPRAY_TANK_CAPACITY")) {
    //     return false;
    // }
    
    // if (!_vehicle->parameterManager()->parameterExists(FactSystem::defaultComponentId, "SPRAY_FLOW_RATE")) {
    //     return false;
    // }
     return true;
 }
 