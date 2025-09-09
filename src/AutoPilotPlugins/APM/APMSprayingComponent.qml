/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

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

            property Fact _sprayEnable:           controller.getParameterFact(-1, "SPRAY_ENABLE")
            property Fact _tankCapacity:          controller.getParameterFact(-1, "SPRAY_TANK_CAPACITY", false)
            property Fact _flowRate:              controller.getParameterFact(-1, "SPRAY_FLOW_RATE", false)
            property Fact _flowMin:               controller.getParameterFact(-1, "SPRAY_FLOW_MIN", false)
            property Fact _flowMonitor:           controller.getParameterFact(-1, "SPRAY_FLOW_MONITOR", false)
            property Fact _flowPin:               controller.getParameterFact(-1, "SPRAY_FLOW_PIN", false)
            property Fact _pumpPin:               controller.getParameterFact(-1, "SPRAY_PUMP_PIN", false)
            property Fact _flowMult:              controller.getParameterFact(-1, "SPRAY_FLOW_MULT", false)
            property Fact _flowOffset:            controller.getParameterFact(-1, "SPRAY_FLOW_OFFSET", false)
            property Fact _tankLow:               controller.getParameterFact(-1, "SPRAY_TANK_LOW", false)
            property Fact _tankCritical:          controller.getParameterFact(-1, "SPRAY_TANK_CRITICAL", false)

            property bool _sprayEnabled:          _sprayEnable.rawValue !== 0
            property bool _flowMonitorEnabled:    _flowMonitor.rawValue !== 0
            property bool _showAdvanced:          false

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            // Spraying System Enable/Disable
            Column {
                spacing: _margins / 2

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
                visible: _sprayEnabled

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
                                fact:       _tankCapacity
                                visible:    _tankCapacity
                            }

                            QGCLabel { text: qsTr("Low Tank Warning:") }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _tankLow
                                visible:    _tankLow
                            }

                            QGCLabel { text: qsTr("Critical Tank Level:") }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _tankCritical
                                visible:    _tankCritical
                            }
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
                visible: _sprayEnabled

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

                            QGCLabel { text: qsTr("Flow Rate:") }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _flowRate
                                visible:    _flowRate
                            }

                            QGCLabel { text: qsTr("Minimum Flow Rate:") }
                            FactTextField {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _flowMin
                                visible:    _flowMin
                            }

                            QGCLabel { text: qsTr("Flow Monitor:") }
                            FactComboBox {
                                width:      ScreenTools.defaultFontPixelWidth * 15
                                fact:       _flowMonitor
                                indexModel: false
                                sizeToContents: true
                                visible:    _flowMonitor
                            }
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
                visible: _sprayEnabled

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
