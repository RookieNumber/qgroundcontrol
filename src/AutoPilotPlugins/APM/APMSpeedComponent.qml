/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.ScreenTools

SetupPage {
    id:             speedPage
    pageComponent:  speedPageComponent

    FactPanelController {
        id: controller
    }

    Component {
        id: speedPageComponent

        Flow {
            id:         flowLayout
            width:      availableWidth
            spacing:    _margins

            property real _margins: ScreenTools.defaultFontPixelHeight

            property Fact _missionSpeed: controller.getParameterFact(-1, "WPNAV_SPEED", false /* reportMissing */)
            property Fact _loiterSpeed:  controller.getParameterFact(-1, "LOIT_SPEED", false /* reportMissing */)

            property bool _missionSpeedAvailable: controller.parameterExists(-1, "WPNAV_SPEED")
            property bool _loiterSpeedAvailable:  controller.parameterExists(-1, "LOIT_SPEED")

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            Column {
                spacing: _margins / 2
                visible: _missionSpeedAvailable

                QGCLabel {
                    text:       qsTr("Mission Speed")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  missionSpeedColumn.x + missionSpeedColumn.width + _margins
                    height: missionSpeedColumn.y + missionSpeedColumn.height + _margins
                    color:  qgcPal.windowShade

                    ColumnLayout {
                        id:                 missionSpeedColumn
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        GridLayout {
                            columns:        2
                            columnSpacing:  _margins
                            rowSpacing:     _margins / 2

                            QGCLabel {
                                text: qsTr("Waypoint cruise speed:")
                            }

                            FactTextField {
                                fact:       _missionSpeed
                                showUnits:  true
                                Layout.fillWidth: true
                            }
                        }

                        QGCLabel {
                            text:       qsTr("Sets the default cruise speed used for waypoint navigation.")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            Column {
                spacing: _margins / 2
                visible: _loiterSpeedAvailable

                QGCLabel {
                    text:       qsTr("Loiter Speed")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  loiterSpeedColumn.x + loiterSpeedColumn.width + _margins
                    height: loiterSpeedColumn.y + loiterSpeedColumn.height + _margins
                    color:  qgcPal.windowShade

                    ColumnLayout {
                        id:                 loiterSpeedColumn
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        GridLayout {
                            columns:        2
                            columnSpacing:  _margins
                            rowSpacing:     _margins / 2

                            QGCLabel {
                                text: qsTr("Manual loiter speed:")
                            }

                            FactTextField {
                                fact:       _loiterSpeed
                                showUnits:  true
                                Layout.fillWidth: true
                            }
                        }

                        QGCLabel {
                            text:       qsTr("Sets the default speed when the vehicle loiters or is manually flown without mission commands.")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            Column {
                spacing: _margins / 2
                visible: !_missionSpeedAvailable && !_loiterSpeedAvailable
                width: flowLayout.width

                QGCLabel {
                    text:       qsTr("Speed configuration is not available.")
                    font.family: ScreenTools.demiboldFontFamily
                }

                QGCLabel {
                    text:       qsTr("The connected vehicle firmware does not expose speed parameters required by this panel.")
                    font.pointSize: ScreenTools.smallFontPointSize
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}