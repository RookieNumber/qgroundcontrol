/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.ScreenTools

SetupPage {
    id:             spreaderPage
    pageComponent:  spreaderPageComponent

    FactPanelController {
        id:         controller
    }

    Component {
        id: spreaderPageComponent

        Flow {
            id:         flowLayout
            width:      availableWidth
            spacing:    _margins
            
            // Spreader system parameters
            property Fact _sprayEnable:           controller.getParameterFact(-1, "SPRAY_ENABLE", false /* reportMissing */)
            property Fact _hopperCapacity:        controller.getParameterFact(-1, "SPRAY_TANK_CAPACITY", false /* reportMissing */)
            property Fact _spreadRate:            controller.getParameterFact(-1, "SPRAY_PUMP_RATE", false /* reportMissing */)
            property Fact _spreadMin:             controller.getParameterFact(-1, "SPRAY_PUMP_MIN", false /* reportMissing */)
            property Fact _spreadMonitor:         controller.getParameterFact(-1, "SPREAD_MONITOR", false /* reportMissing */)
            property Fact _spreadPin:             controller.getParameterFact(-1, "SPRAY_FLOW_PIN", false /* reportMissing */)
            property Fact _motorPin:              controller.getParameterFact(-1, "SPRAY_PUMP_PIN", false /* reportMissing */)
            property Fact _spreadMult:            controller.getParameterFact(-1, "SPRAY_FLOW_MULT", false /* reportMissing */)
            property Fact _spreadOffset:          controller.getParameterFact(-1, "SPRAY_FLOW_OFFSET", false /* reportMissing */)
            property Fact _hopperLow:             controller.getParameterFact(-1, "SPRAY_TANK_LOW", false /* reportMissing */)
            property Fact _hopperCritical:        controller.getParameterFact(-1, "SPRAY_TANK_CRITICAL", false /* reportMissing */)
            property Fact _batt2Capacity:         controller.getParameterFact(-1, "BATT2_CAPACITY", false /* reportMissing */)

            // Parameter availability checks
            property bool _sprayEnableAvailable:  controller.parameterExists(-1, "SPRAY_ENABLE")
            property bool _spreadRateAvailable:   controller.parameterExists(-1, "SPRAY_PUMP_RATE")
            property bool _spreadMinAvailable:    controller.parameterExists(-1, "SPRAY_PUMP_MIN")
            property bool _batt2CapacityAvailable: controller.parameterExists(-1, "BATT2_CAPACITY")

            // State properties
            property bool _spreadEnabled:         _sprayEnableAvailable && _sprayEnable.rawValue !== 0
            property bool _spreadMonitorEnabled:  _spreadMonitor ? _spreadMonitor.rawValue !== 0 : false
            property bool _showAdvanced:          false

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            // Message when spreader is not available
            Column {
                spacing: _margins
                visible: !_sprayEnableAvailable
                width: parent.width

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       qsTr("Spreader system is not available on this vehicle. The vehicle firmware may not support spreading or the SPRAY_ENABLE parameter is missing.")
                    font.pointSize: ScreenTools.mediumFontPointSize
                }
            }

            // Spreader System Enable/Disable
            Column {
                spacing: _margins / 2
                visible: _sprayEnableAvailable

                QGCLabel {
                    text:       qsTr("Spreader System")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  spreadEnableColumn.x + spreadEnableColumn.width + _margins
                    height: spreadEnableColumn.y + spreadEnableColumn.height + _margins
                    color:  qgcPal.windowShade

                    ColumnLayout {
                        id:                 spreadEnableColumn
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        RowLayout {
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Spreader System:") }
                            FactComboBox {
                                id:         spreadEnableCombo
                                fact:       _sprayEnable
                                indexModel: false
                                sizeToContents: true
                            }
                        }

                        QGCLabel {
                            text:       qsTr("Enable or disable the spreader system")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            visible:    true
                        }
                    }
                }
            }

            // Hopper Configuration
            Column {
                spacing: _margins / 2
                // visible: _sprayEnableAvailable && _spreadEnabled
                visible: false

                QGCLabel {
                    text:       qsTr("Hopper Configuration")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  hopperConfigColumn.x + hopperConfigColumn.width + _margins
                    height: hopperConfigColumn.y + hopperConfigColumn.height + _margins
                    color:  qgcPal.windowShade

                    ColumnLayout {
                        id:                 hopperConfigColumn
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        GridLayout {
                            columns:        2
                            rowSpacing:     _margins
                            columnSpacing:  _margins

                            QGCLabel { text: qsTr("Hopper Capacity:") }

                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _batt2Capacity
                                visible:    true
                                unitsLabel: "kg"
                            }

                            // QGCLabel { text: qsTr("Low Hopper Warning:") }
                            // FactTextField {
                            //     width:      ScreenTools.defaultFontPixelWidth * 15
                            //     fact:       _hopperLow
                            //     visible:    _hopperLow
                            // }

                            // QGCLabel { text: qsTr("Critical Hopper Level:") }
                            // FactTextField {
                            //     width:      ScreenTools.defaultFontPixelWidth * 15
                            //     fact:       _hopperCritical
                            //     visible:    _hopperCritical
                            // }
                        }

                        QGCLabel {
                            text:       qsTr("Configure hopper capacity and warning levels for material monitoring")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Spread Control Configuration
            Column {
                spacing: _margins / 2
                visible: _sprayEnableAvailable && _spreadEnabled

                QGCLabel {
                    text:       qsTr("Spread Control")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  spreadConfigColumn.x + spreadConfigColumn.width + _margins
                    height: spreadConfigColumn.y + spreadConfigColumn.height + _margins
                    color:  qgcPal.windowShade

                    ColumnLayout {
                        id:                 spreadConfigColumn
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        GridLayout {
                            columns:        2
                            rowSpacing:     _margins
                            columnSpacing:  _margins

                            QGCLabel { 
                                text: qsTr("Spread Rate:")
                                visible: _spreadRateAvailable
                            }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _spreadRate
                                visible:    _spreadRateAvailable
                            }

                            QGCLabel { 
                                text: qsTr("Minimum Spread Rate:")
                                visible: _spreadMinAvailable
                            }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _spreadMin
                                visible:    _spreadMinAvailable
                            }

                            // QGCLabel { text: qsTr("Spread Monitor:") }
                            // FactComboBox {
                            //     width:      ScreenTools.defaultFontPixelWidth * 15
                            //     fact:       _spreadMonitor
                            //     indexModel: false
                            //     sizeToContents: true
                            //     visible:    _spreadMonitor
                            // }
                        }

                        QGCLabel {
                            text:       qsTr("Configure spread rate settings and monitoring")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Advanced Settings
            Column {
                spacing: _margins / 2
                // visible: _sprayEnableAvailable && _spreadEnabled
                visible: false

                QGCLabel {
                    text:       qsTr("Advanced Settings")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  advancedConfigColumn.x + advancedConfigColumn.width + _margins
                    height: advancedConfigColumn.y + advancedConfigColumn.height + _margins
                    color:  qgcPal.windowShade

                    ColumnLayout {
                        id:                 advancedConfigColumn
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        QGCButton {
                            text: _showAdvanced ? qsTr("Hide Advanced") : qsTr("Show Advanced")
                            onClicked: _showAdvanced = !_showAdvanced
                        }

                        GridLayout {
                            columns:        2
                            rowSpacing:     _margins
                            columnSpacing:  _margins
                            visible:        _showAdvanced

                            QGCLabel { text: qsTr("Spread Sensor Pin:") }
                            FactComboBox {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _spreadPin
                                indexModel: false
                                sizeToContents: true
                                visible:    _spreadPin
                            }

                            QGCLabel { text: qsTr("Motor Control Pin:") }
                            FactComboBox {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _motorPin
                                indexModel: false
                                sizeToContents: true
                                visible:    _motorPin
                            }

                            QGCLabel { text: qsTr("Spread Multiplier:") }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _spreadMult
                                visible:    _spreadMult
                            }

                            QGCLabel { text: qsTr("Spread Offset:") }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _spreadOffset
                                visible:    _spreadOffset
                            }
                        }

                        QGCLabel {
                            text:       qsTr("Advanced hardware configuration for spread sensors and motor control")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            Layout.fillWidth: true
                            visible:    _showAdvanced
                        }
                    }
                }
            }
        } // Flow
    } // Component - spreaderPageComponent
} // SetupPage
