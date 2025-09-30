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

            // PX4 does not define SPRAY_* params by default; this UI is opportunistic
            // and only shows fields when params exist.

            property Fact _sprayEnable:           controller.getParameterFact(-1, "SPRAY_ENABLE", false)
            property Fact _tankCapacity:          controller.getParameterFact(-1, "SPRAY_TANK_CAPACITY", false)
            property Fact _flowRate:              controller.getParameterFact(-1, "SPRAY_FLOW_RATE", false)
            property Fact _flowMin:               controller.getParameterFact(-1, "SPRAY_PUMP_MIN", false)
            property Fact _flowMonitor:           controller.getParameterFact(-1, "SPRAY_FLOW_MONITOR", false)
            property Fact _flowPin:               controller.getParameterFact(-1, "SPRAY_FLOW_PIN", false)
            property Fact _pumpPin:               controller.getParameterFact(-1, "SPRAY_PUMP_PIN", false)
            property Fact _flowMult:              controller.getParameterFact(-1, "SPRAY_FLOW_MULT", false)
            property Fact _flowOffset:            controller.getParameterFact(-1, "SPRAY_FLOW_OFFSET", false)
            property Fact _tankLow:               controller.getParameterFact(-1, "SPRAY_TANK_LOW", false)
            property Fact _tankCritical:          controller.getParameterFact(-1, "SPRAY_TANK_CRITICAL", false)

            // Local fallback values when PX4 parameters are not present
            property int    _localSprayEnable:    0
            property string _localTankCapacity:   ""
            property string _localFlowRate:       ""
            property string _localFlowMin:        ""
            property int    _localFlowPin:        0
            property int    _localPumpPin:        0
            property string _localFlowMult:       ""
            property string _localFlowOffset:     ""

            property bool _sprayEnabled:          (_sprayEnable && _sprayEnable.rawValue !== 0) || (!_sprayEnable && _localSprayEnable !== 0)
            property bool _flowMonitorEnabled:    _flowMonitor && _flowMonitor.rawValue !== 0
            property bool _hasAnySprayParams:     _sprayEnable || _tankCapacity || _flowRate || _flowMin || _flowMonitor || _flowPin || _pumpPin || _flowMult || _flowOffset || _tankLow || _tankCritical

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            // Message if PX4 firmware does not expose any SPRAY_* parameters
            Column {
                spacing: _margins / 2
                visible: !_hasAnySprayParams

                Rectangle {
                    width:  flowLayout.width
                    color:  qgcPal.windowShade

                    ColumnLayout {
                        id:             noParamColumn
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            text:       qsTr("No spraying parameters detected on this PX4 firmware.")
                            wrapMode:   Text.WordWrap
                        }
                        QGCLabel {
                            text:       qsTr("This panel requires custom PX4 parameters (SPRAY_*). The UI will show controls automatically when those parameters are present.")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                        }
                    }
                    implicitHeight: noParamColumn.implicitHeight + _margins * 2
                }
            }

            Column {
                spacing: _margins / 2
                visible: true

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
                                visible:    _sprayEnable
                            }
                            QGCComboBox {
                                id:                 sprayEnableFallback
                                visible:            !_sprayEnable
                                model:              [ qsTr("Disabled"), qsTr("Enabled") ]
                                currentIndex:       _localSprayEnable
                                onActivated:        _localSprayEnable = index
                                sizeToContents:     true
                            }
                        }

                        QGCLabel {
                            text:       qsTr("Enable or disable the spraying system")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            visible:    _sprayEnable
                        }
                    }
                }
            }

            Column {
                spacing: _margins / 2
                visible: true

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
                            Item {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                                implicitHeight: childrenRect.height
                                FactTextField {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    fact:       _tankCapacity
                                    visible:    _tankCapacity
                                    unitsLabel: "mL"
                                }
                                Row {
                                    spacing: ScreenTools.defaultFontPixelWidth
                                    visible:    !_tankCapacity
                                    QGCTextField {
                                        width:      ScreenTools.defaultFontPixelWidth * 15
                                        text:       _localTankCapacity
                                        onEditingFinished: _localTankCapacity = text
                                    }
                                    QGCLabel { text: "mL" }
                                }
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

            Column {
                spacing: _margins / 2
                visible: true

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
                            Item {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                                implicitHeight: childrenRect.height
                                FactTextField {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    fact:       _flowRate
                                    visible:    _flowRate
                                }
                                QGCTextField {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    visible:    !_flowRate
                                    text:       _localFlowRate
                                    onEditingFinished: _localFlowRate = text
                                }
                            }

                            QGCLabel { text: qsTr("Minimum Flow Rate:") }
                            Item {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                                implicitHeight: childrenRect.height
                                FactTextField {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    fact:       _flowMin
                                    visible:    _flowMin
                                }
                                QGCTextField {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    visible:    !_flowMin
                                    text:       _localFlowMin
                                    onEditingFinished: _localFlowMin = text
                                }
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

            Column {
                spacing: _margins / 2
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

                        GridLayout {
                            columns:        2
                            rowSpacing:     _margins
                            columnSpacing:  _margins

                            QGCLabel { text: qsTr("Flow Sensor Pin:") }
                            Item {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                                implicitHeight: childrenRect.height
                                FactComboBox {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    fact:       _flowPin
                                    indexModel: false
                                    sizeToContents: true
                                    visible:    _flowPin
                                }
                                QGCComboBox {
                                    visible:    !_flowPin
                                    model:      ["0","1","2","3","4","5","6","7","8","9"]
                                    currentIndex: _localFlowPin
                                    onActivated: _localFlowPin = index
                                }
                            }

                            QGCLabel { text: qsTr("Pump Control Pin:") }
                            Item {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                                implicitHeight: childrenRect.height
                                FactComboBox {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    fact:       _pumpPin
                                    indexModel: false
                                    sizeToContents: true
                                    visible:    _pumpPin
                                }
                                QGCComboBox {
                                    visible:    !_pumpPin
                                    model:      ["0","1","2","3","4","5","6","7","8","9"]
                                    currentIndex: _localPumpPin
                                    onActivated: _localPumpPin = index
                                }
                            }

                            QGCLabel { text: qsTr("Flow Multiplier:") }
                            Item {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                                implicitHeight: childrenRect.height
                                FactTextField {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    fact:       _flowMult
                                    visible:    _flowMult
                                }
                                QGCTextField {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    visible:    !_flowMult
                                    text:       _localFlowMult
                                    onEditingFinished: _localFlowMult = text
                                }
                            }

                            QGCLabel { text: qsTr("Flow Offset:") }
                            Item {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                                implicitHeight: childrenRect.height
                                FactTextField {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    fact:       _flowOffset
                                    visible:    _flowOffset
                                }
                                QGCTextField {
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    visible:    !_flowOffset
                                    text:       _localFlowOffset
                                    onEditingFinished: _localFlowOffset = text
                                }
                            }
                        }

                        QGCLabel {
                            text:       qsTr("Advanced hardware configuration for flow sensors and pump control")
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode:   Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}


