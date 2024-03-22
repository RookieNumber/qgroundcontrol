/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick              2.3
import QtQuick.Controls     1.2
import QtGraphicalEffects   1.0
import QtQuick.Layouts      1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

SetupPage {
    id:             speedPage
    pageComponent:  speedPageComponent

    Component {
        id: speedPageComponent

        Flow {
            id:         flowLayout
            width:      availableWidth
            spacing:    _margins

            FactPanelController { id: controller; }

            QGCPalette { id: ggcPal; colorGroupEnabled: true }

            property Fact _batt1Monitor:                    controller.getParameterFact(-1, "BATT_MONITOR")
            property Fact _batt2Monitor:                    controller.getParameterFact(-1, "BATT2_MONITOR", false /* reportMissing */)
            property bool _batt2MonitorAvailable:           controller.parameterExists(-1, "BATT2_MONITOR")
            property bool _batt1MonitorEnabled:             _batt1Monitor.rawValue !== 0
            property bool _batt2MonitorEnabled:             _batt2MonitorAvailable ? _batt2Monitor.rawValue !== 0 : false
            property bool _batt1ParamsAvailable:            controller.parameterExists(-1, "BATT_CAPACITY")
            property bool _batt2ParamsAvailable:            controller.parameterExists(-1, "BATT2_CAPACITY")

            property Fact _failsafeBatt1LowAct:             controller.getParameterFact(-1, "BATT_FS_LOW_ACT", false /* reportMissing */)
            property Fact _failsafeBatt2LowAct:             controller.getParameterFact(-1, "BATT2_FS_LOW_ACT", false /* reportMissing */)
            property Fact _failsafeBatt1CritAct:            controller.getParameterFact(-1, "BATT_FS_CRT_ACT", false /* reportMissing */)
            property Fact _failsafeBatt2CritAct:            controller.getParameterFact(-1, "BATT2_FS_CRT_ACT", false /* reportMissing */)
            property Fact _failsafeBatt1LowMah:             controller.getParameterFact(-1, "BATT_LOW_MAH", false /* reportMissing */)
            property Fact _failsafeBatt2LowMah:             controller.getParameterFact(-1, "BATT2_LOW_MAH", false /* reportMissing */)
            property Fact _failsafeBatt1CritMah:            controller.getParameterFact(-1, "BATT_CRT_MAH", false /* reportMissing */)
            property Fact _failsafeBatt2CritMah:            controller.getParameterFact(-1, "BATT2_CRT_MAH", false /* reportMissing */)
            property Fact _failsafeBatt1LowVoltage:         controller.getParameterFact(-1, "BATT_LOW_VOLT", false /* reportMissing */)
            property Fact _failsafeBatt2LowVoltage:         controller.getParameterFact(-1, "BATT2_LOW_VOLT", false /* reportMissing */)
            property Fact _failsafeBatt1CritVoltage:        controller.getParameterFact(-1, "BATT_CRT_VOLT", false /* reportMissing */)
            property Fact _failsafeBatt2CritVoltage:        controller.getParameterFact(-1, "BATT2_CRT_VOLT", false /* reportMissing */)


            property Fact _waypointSpeed:                   controller.getParameterFact(-1, "WPNAV_SPEED", false)
            property Fact _loiterSpeed:                     controller.getParameterFact(-1, "LOIT_SPEED", false)

            property Fact _armingCheck: controller.getParameterFact(-1, "ARMING_CHECK")

            property real _margins:         ScreenTools.defaultFontPixelHeight
            property real _innerMargin:     _margins / 2
            property bool _showIcon:        !ScreenTools.isTinyScreen
            property bool _roverFirmware:   controller.parameterExists(-1, "MODE1") // This catches all usage of ArduRover firmware vehicle types: Rover, Boat...


            property string _restartRequired: qsTr("Requires vehicle reboot")

            Component {
                id: batteryFailsafeComponent

                Column {
                    spacing: _margins

                    GridLayout {
                        id:             gridLayout
                        columns:        2
                        rowSpacing:     _margins
                        columnSpacing:  _margins

                        QGCLabel {
                            Layout.row:     1
                            Layout.column:  0
                            text:           qsTr("Kecepatan Terbang pada Saat Misi:")
                            visible: true
                        }

                        FactTextField {

                            fact:   _waypointSpeed
                            visible:   true
                            showUnits: true
                        }

                        QGCLabel {
                           Layout.columnSpan:  2
                           Layout.fillWidth:  true
                           font.pointSize:     ScreenTools.smallFontPointSize
                           wrapMode:           Text.WordWrap
                           text:               qsTr("Nilai kecepatan terbang drone saat melakukan terbang spraying secara otomatis.")
                           visible:            true
                       }


                        QGCLabel {
                            Layout.row:     3
                            Layout.column:  0
                            text:           qsTr("Kecepatan Terbang pada mode Loiter:")
                            visible: true
                        }

                        FactTextField {

                            fact:   _loiterSpeed
                            visible:   true
                            showUnits: true
                        }

                        QGCLabel {
                           Layout.columnSpan:  2
                           Layout.fillWidth:  true
                           font.pointSize:     ScreenTools.smallFontPointSize
                           wrapMode:           Text.WordWrap
                           text:               qsTr("Nilai kecepatan terbang drone saat melakukan terbang kendali pilot.")
                           visible:            true
                       }


                    } // GridLayout
                } // Column
            }

            Component {
                id: restartRequiredComponent

                ColumnLayout {
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCLabel {
                        text: _restartRequired
                    }

                    QGCButton {
                        text:       qsTr("Restart Drone")
                        onClicked:  controller.vehicle.rebootVehicle()
                    }
                }
            }

            Column {
                spacing: _margins / 2
                visible: _batt1MonitorEnabled

                QGCLabel {
                    text:       qsTr("Kecepatan Terbang saat Terbang Melewati Waypoint")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  battery1FailsafeLoader.x + battery1FailsafeLoader.width + _margins
                    height: battery1FailsafeLoader.y + battery1FailsafeLoader.height + _margins
                    color:  ggcPal.windowShade

                    Loader {
                        id:                 battery1FailsafeLoader
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        sourceComponent:    _batt1ParamsAvailable ? batteryFailsafeComponent : restartRequiredComponent

                        property Fact battMonitor:              _batt1Monitor
                        property bool battParamsAvailable:      _batt1ParamsAvailable
                        property Fact failsafeBattLowAct:       _failsafeBatt1LowAct
                        property Fact failsafeBattCritAct:      _failsafeBatt1CritAct
                        property Fact failsafeBattLowMah:       _failsafeBatt1LowMah
                        property Fact failsafeBattCritMah:      _failsafeBatt1CritMah
                        property Fact failsafeBattLowVoltage:   _failsafeBatt1LowVoltage
                        property Fact failsafeBattCritVoltage:  _failsafeBatt1CritVoltage
                    }
                } // Rectangle
            } // Column - Battery Failsafe Settings
        } // Flow
    } // Component - safetyPageComponent
} // SetupView
