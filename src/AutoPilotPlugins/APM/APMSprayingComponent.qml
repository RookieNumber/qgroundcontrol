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
    id:             sprayingPage
    pageComponent:  sprayingPageComponent

    FactPanelController {
        id:         controller
    }

    Component {
        id: sprayingPageComponent

        Flow {
            id:         flowLayout
            width:      availableWidth
            spacing:    _margins
            
            // Parameters
            property Fact _sprayEnable:             controller.getParameterFact(-1, "SPRAY_ENABLE", false /* reportMissing */)
            property Fact _tankCapacity:            controller.getParameterFact(-1, "SPRAY_TANK_CAPACITY", false /* reportMissing */)
            property Fact _flowRate:                controller.getParameterFact(-1, "SPRAY_PUMP_RATE", false /* reportMissing */)
            property Fact _flowMin:                 controller.getParameterFact(-1, "SPRAY_PUMP_MIN", false /* reportMissing */)
            property Fact _flowMonitor:             controller.getParameterFact(-1, "SPRAY_FLOW_MONITOR", false /* reportMissing */)
            property Fact _flowPin:                 controller.getParameterFact(-1, "SPRAY_FLOW_PIN", false /* reportMissing */)
            property Fact _pumpPin:                 controller.getParameterFact(-1, "SPRAY_PUMP_PIN", false /* reportMissing */)
            property Fact _flowMult:                controller.getParameterFact(-1, "SPRAY_FLOW_MULT", false /* reportMissing */)
            property Fact _flowOffset:              controller.getParameterFact(-1, "SPRAY_FLOW_OFFSET", false /* reportMissing */)
            property Fact _tankLow:                 controller.getParameterFact(-1, "SPRAY_TANK_LOW", false /* reportMissing */)
            property Fact _tankCritical:            controller.getParameterFact(-1, "SPRAY_TANK_CRITICAL", false /* reportMissing */)
            property Fact _batt2Capacity:           controller.getParameterFact(-1, "BATT2_CAPACITY", false /* reportMissing */)

            // Parameter availability checks
            property bool _sprayEnableAvailable:    controller.parameterExists(-1, "SPRAY_ENABLE")
            property bool _tankCapacityAvailable:   controller.parameterExists(-1, "SPRAY_TANK_CAPACITY")
            property bool _flowRateAvailable:       controller.parameterExists(-1, "SPRAY_PUMP_RATE")
            property bool _flowMinAvailable:        controller.parameterExists(-1, "SPRAY_PUMP_MIN")
            property bool _flowMonitorAvailable:    controller.parameterExists(-1, "SPRAY_FLOW_MONITOR")
            property bool _batt2CapacityAvailable:  controller.parameterExists(-1, "BATT2_CAPACITY")

            // State properties
            property bool _sprayEnabled:            _sprayEnableAvailable && _sprayEnable.rawValue !== 0
            property bool _flowMonitorEnabled:      _flowMonitorAvailable && _flowMonitor.rawValue !== 0
            property bool _showAdvanced:            false

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            // Message when spraying is not available
            Column {
                spacing: _margins
                visible: !_sprayEnableAvailable
                width: parent.width

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       qsTr("Spraying system is not available on this vehicle. The vehicle firmware may not support spraying or the SPRAY_ENABLE parameter is missing.")
                    font.pointSize: ScreenTools.mediumFontPointSize
                }
            }

            // Spraying System Enable/Disable
            Column {
                spacing: _margins / 2
                visible: _sprayEnableAvailable

                QGCLabel {
                    text:       qsTr("Spraying System")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  sprayEnableColumn.x + sprayEnableColumn.width + _margins
                    height: sprayEnableColumn.y + sprayEnableColumn.height + _margins
                    color:  qgcPal.windowShade

                    ColumnLayout {
                        id:                 sprayEnableColumn
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        RowLayout {
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Spraying System:") }
                            FactComboBox {
                                id:         sprayEnableCombo
                                fact:       _sprayEnable
                                indexModel: false
                                sizeToContents: true
                            }
                        }

                        QGCLabel {
                            text:       qsTr("Enable or disable the spraying system")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            visible:    true
                        }
                    }
                }
            }

            // Tank Configuration
            Column {
                spacing: _margins / 2
                visible: _sprayEnableAvailable && _sprayEnabled

                QGCLabel {
                    text:       qsTr("Tank Configuration")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  tankConfigColumn.x + tankConfigColumn.width + _margins
                    height: tankConfigColumn.y + tankConfigColumn.height + _margins
                    color:  qgcPal.windowShade

                    ColumnLayout {
                        id:                 tankConfigColumn
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        GridLayout {
                            columns:        2
                            rowSpacing:     _margins
                            columnSpacing:  _margins

                            QGCLabel { text: qsTr("Tank Capacity:") }


                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _batt2Capacity
                                visible:    true
                                unitsLabel: "mL"
                            }

                            // QGCLabel { text: qsTr("Low Tank Warning:") }
                            // FactTextField {
                            //     width:      ScreenTools.defaultFontPixelWidth * 15
                            //     fact:       _tankLow
                            //     visible:    _tankLow
                            // }

                            // QGCLabel { text: qsTr("Critical Tank Level:") }
                            // FactTextField {
                            //     width:      ScreenTools.defaultFontPixelWidth * 15
                            //     fact:       _tankCritical
                            //     visible:    _tankCritical
                            // }
                        }

                        QGCLabel {
                            text:       qsTr("Configure tank capacity and warning levels for liquid monitoring")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            Layout.fillWidth: true
                        }


                    }
                }
            }

            // Flow Control Configuration
            Column {
                spacing: _margins / 2
                visible: _sprayEnableAvailable && _sprayEnabled

                QGCLabel {
                    text:       qsTr("Flow Control")
                    font.family: ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    width:  flowConfigColumn.x + flowConfigColumn.width + _margins
                    height: flowConfigColumn.y + flowConfigColumn.height + _margins
                    color:  qgcPal.windowShade

                    ColumnLayout {
                        id:                 flowConfigColumn
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        GridLayout {
                            columns:        2
                            rowSpacing:     _margins
                            columnSpacing:  _margins

                            QGCLabel { 
                                text: qsTr("Flow Rate:")
                                visible: _flowRateAvailable
                            }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _flowRate
                                visible:    _flowRateAvailable
                            }

                            QGCLabel { 
                                text: qsTr("Minimum Flow Rate:")
                                visible: _flowMinAvailable
                            }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _flowMin
                                visible:    _flowMinAvailable
                            }

                            // QGCLabel { text: qsTr("Flow Monitor:") }
                            // FactComboBox {
                            //     width:      ScreenTools.defaultFontPixelWidth * 15
                            //     fact:       _flowMonitor
                            //     indexModel: false
                            //     sizeToContents: true
                            //     visible:    _flowMonitor
                            // }
                        }

                        QGCLabel {
                            text:       qsTr("Configure flow rate settings and monitoring")
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
                // visible: _sprayEnabled
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

                            QGCLabel { text: qsTr("Flow Sensor Pin:") }
                            FactComboBox {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _flowPin
                                indexModel: false
                                sizeToContents: true
                                visible:    _flowPin
                            }

                            QGCLabel { text: qsTr("Pump Control Pin:") }
                            FactComboBox {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _pumpPin
                                indexModel: false
                                sizeToContents: true
                                visible:    _pumpPin
                            }

                            QGCLabel { text: qsTr("Flow Multiplier:") }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _flowMult
                                visible:    _flowMult
                            }

                            QGCLabel { text: qsTr("Flow Offset:") }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _flowOffset
                                visible:    _flowOffset
                            }
                        }

                        QGCLabel {
                            text:       qsTr("Advanced hardware configuration for flow sensors and pump control")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            Layout.fillWidth: true
                            visible:    _showAdvanced
                        }
                    }
                }
            }
        } // Flow
    } // Component - sprayingPageComponent
} // SetupPage
