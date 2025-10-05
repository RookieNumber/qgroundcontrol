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
 
 class APMSpreaderComponent : public VehicleComponent
 {
     Q_OBJECT
 
 public:
     APMSpreaderComponent(Vehicle *vehicle, AutoPilotPlugin *autopilot, QObject *parent = nullptr);
 
     QStringList setupCompleteChangedTriggerList() const final { return QStringList(); }
 
     QString name() const final { return _name; }
     QString description() const final { return tr("The Spreader Component is used to setup spreader parameters."); }
     QString iconResource() const final { return QStringLiteral("/qmlimages/SpreaderIcon.svg"); }
     bool requiresSetup() const final { return false; }
     bool setupComplete() const final { return true; }
     QUrl setupSource() const final { return QUrl::fromUserInput(QStringLiteral("qrc:/qml/QGroundControl/AutoPilotPlugins/APM/APMSpreaderComponent.qml")); }
     QUrl summaryQmlSource() const final { return QUrl::fromUserInput(QStringLiteral("qrc:/qml/QGroundControl/AutoPilotPlugins/APM/APMSpreaderComponentSummary.qml")); }
     bool allowSetupWhileArmed() const final { return true; }
 
 private:
     const QString _name = tr("Spreader");
 };
 