/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                      2.3
import QtQuick.Controls             1.2
import QtQuick.Layouts              1.2

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

SetupPage {
    id:             sprayingPage
    pageComponent:  sprayingPageComponent

    Component {
        id: sprayingPageComponent

        Item {
            width:  Math.max(availableWidth, innerColumn.width)
            height: innerColumn.height

            FactPanelController {
                id:         controller
            }

            property real _margins:         ScreenTools.defaultFontPixelHeight

            // Contain property for frogs custom parameters
            property Fact _tankcFull:              controller.getParameterFact(-1, "SPRAY_C_FULL", false /* reportMissing */)
            property Fact _tankFull:               controller.getParameterFact(-1, "SPRAY_FULL", false /* reportMissing */)
            property Fact _tankPIDEnable:           controller.getParameterFact(-1, "SPRAY_PID_EN", false /* reportMissing */)
            property Fact _tankPFlow:              controller.getParameterFact(-1, "SPRAY_P_FLOW", false /* reportMissing */)
            property Fact _tankIFlow:              controller.getParameterFact(-1, "SPRAY_I_FLOW", false /* reportMissing */)
            property Fact _tankDFlow:               controller.getParameterFact(-1, "SPRAY_D_FLOW", false /* reportMissing */)
            property Fact _tankMaxFlow:            controller.getParameterFact(-1, "SPRAY_MAX_FLOW", false /* reportMissing */)
            property Fact _tankSetFlow:            controller.getParameterFact(-1, "SPRAY_SET_FLOW", false /* reportMissing */)
            property Fact _tankTRt:                controller.getParameterFact(-1, "SPRAY_T_RTL", false /* reportMissing */)

            // Contain paramter availability checks
            property bool _tankcFullAvailable:       controller.parameterExists(-1, "SPRAY_C_FULL")
            property bool _tankFullAvailable:        controller.parameterExists(-1, "SPRAY_FULL")
            property bool _tankPIDEnableAvailable:   controller.parameterExists(-1, "SPRAY_PID_EN")
            property bool _tankPFlowAvailable:       controller.parameterExists(-1, "SPRAY_P_FLOW")
            property bool _tankIFlowAvailable:       controller.parameterExists(-1, "SPRAY_I_FLOW")
            property bool _tankDFlowAvailable:       controller.parameterExists(-1, "SPRAY_D_FLOW")
            property bool _tankMaxFlowAvailable:     controller.parameterExists(-1, "SPRAY_MAX_FLOW")
            property bool _tankSetFlowAvailable:     controller.parameterExists(-1, "SPRAY_SET_FLOW")
            property bool _tankTRtAvailable:         controller.parameterExists(-1, "SPRAY_T_RTL")

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            ColumnLayout {
                id:                         innerColumn
                anchors.left:               parent.left
                spacing:                    _margins

                // Debug message when spraying parameters are not available
                Column {
                    spacing: _margins
                    visible: !_tankSetFlowAvailable
                    Layout.fillWidth: true

                    QGCLabel {
                        width:      parent.width
                        wrapMode:   Text.WordWrap
                        text:       qsTr("DEBUG MODE: Spraying system parameters are not available on this vehicle. The vehicle firmware may not support spraying or the required parameters are missing. This component is shown for debugging purposes.")
                        font.pointSize: ScreenTools.mediumFontPointSize
                        color:      qgcPal.colorOrange
                    }
                }

                // Tank Configuration
                QGCGroupBox {
                    title:              qsTr("Tank Configuration") + (!_tankFullAvailable ? " (DEBUG)" : "")
                    Layout.fillWidth:   true

                    ColumnLayout {
                        spacing: _margins

                        RowLayout {
                            spacing: _margins
                            Layout.fillWidth: true

                            QGCLabel {
                                text:       qsTr("Volume Tanki Kalibrasi")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: _margins

                                FactTextField {
                                    Layout.fillWidth:   true
                                    fact:               _tankcFull
                                    showUnits:          true
                                    inputMethodHints:   Qt.ImhFormattedNumbersOnly
                                    validator:          DoubleValidator { bottom: 0; decimals: 2 }
                                }

                                QGCLabel {
                                    text:       qsTr("SPRAY_C_FULL parameter not found")
                                    visible:    !_tankcFullAvailable
                                    color:      qgcPal.colorOrange
                                    font.pointSize: ScreenTools.smallFontPointSize
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: _margins

                            QGCLabel {
                                text:       qsTr("Volume Tanki")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: _margins

                                FactTextField {
                                    Layout.fillWidth:   true
                                    fact:               _tankFull
                                    showUnits:          true
                                    inputMethodHints:   Qt.ImhFormattedNumbersOnly
                                    validator:          DoubleValidator { bottom: 0; decimals: 2 }
                                }

                                QGCLabel {
                                    text:       qsTr("SPRAY_FULL parameter not found")
                                    visible:    !_tankFullAvailable
                                    color:      qgcPal.colorOrange
                                    font.pointSize: ScreenTools.smallFontPointSize
                                }
                            }
                        }

                        RowLayout {
                            spacing: _margins
                            Layout.fillWidth: true

                            QGCLabel {
                                text:       qsTr("SPRAY_I_FLOW")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: _margins

                                FactTextField {
                                    Layout.fillWidth:   true
                                    fact:               _tankIFlow
                                    showUnits:          true
                                    inputMethodHints:   Qt.ImhFormattedNumbersOnly
                                    validator:          DoubleValidator { bottom: 0; decimals: 2 }
                                }

                                QGCLabel {
                                    text:       qsTr("SPRAY_I_FLOW parameter not found")
                                    visible:    !_tankIFlowAvailable
                                    color:      qgcPal.colorOrange
                                    font.pointSize: ScreenTools.smallFontPointSize
                                }
                            }
                        }

                        RowLayout {
                            spacing: _margins
                            Layout.fillWidth: true

                            QGCLabel {
                                text:       qsTr("SPRAY_P_FLOW")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: _margins

                                FactTextField {
                                    Layout.fillWidth:   true
                                    fact:               _tankPFlow
                                    showUnits:          true
                                    inputMethodHints:   Qt.ImhFormattedNumbersOnly
                                    validator:          DoubleValidator { bottom: 0; decimals: 2 }
                                }

                                QGCLabel {
                                    text:       qsTr("SPRAY_P_FLOW parameter not found")
                                    visible:    !_tankPFlowAvailable
                                    color:      qgcPal.colorOrange
                                    font.pointSize: ScreenTools.smallFontPointSize
                                }
                            }
                        }
                    }
                }

                // Flow Control Configuration
                QGCGroupBox {
                    title:              qsTr("Flow Control") + (!_tankSetFlowAvailable ? " (DEBUG)" : "")
                    Layout.fillWidth:   true

                    ColumnLayout {
                        spacing: _margins

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: _margins

                            QGCLabel {
                                text:       qsTr("Flow Rate")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: _margins

                                FactTextField {
                                    Layout.fillWidth:   true
                                    fact:               _tankSetFlow
                                    showUnits:          true
                                    inputMethodHints:   Qt.ImhFormattedNumbersOnly
                                    validator:          DoubleValidator { bottom: 0; decimals: 2 }
                                }

                                QGCLabel {
                                    text:       qsTr("SPRAY_SET_FLOW parameter not found")
                                    visible:    !_tankSetFlowAvailable
                                    color:      qgcPal.colorOrange
                                    font.pointSize: ScreenTools.smallFontPointSize
                                }
                            }
                        }

                        RowLayout {
                            spacing: _margins
                            Layout.fillWidth: true

                            QGCLabel {
                                text:       qsTr("Flow Rate Kalibrasi")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: _margins

                                FactTextField {
                                    Layout.fillWidth:   true
                                    fact:               _tankMaxFlow
                                    showUnits:          true
                                    inputMethodHints:   Qt.ImhFormattedNumbersOnly
                                    validator:          DoubleValidator { bottom: 0; decimals: 2 }
                                }

                                QGCLabel {
                                    text:       qsTr("SPRAY_MAX_FLOW parameter not found")
                                    visible:    !_tankMaxFlowAvailable
                                    color:      qgcPal.colorOrange
                                    font.pointSize: ScreenTools.smallFontPointSize
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: _margins

                            QGCLabel {
                                text:       qsTr("RTL Treshold")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: _margins

                                FactTextField {
                                    Layout.fillWidth:   true
                                    fact:               _tankTRt
                                    showUnits:          true
                                    inputMethodHints:   Qt.ImhFormattedNumbersOnly
                                    validator:          DoubleValidator { bottom: 0; decimals: 1 }
                                }

                                QGCLabel {
                                    text:       qsTr("SPRAY_T_RTL parameter not found")
                                    visible:    !_tankTRtAvailable
                                    color:      qgcPal.colorOrange
                                    font.pointSize: ScreenTools.smallFontPointSize
                                }
                            }
                        }

                        // PID Enable checkbox
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: _margins

                            QGCLabel {
                                text:       qsTr("PID Enable")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: _margins

                                FactCheckBox {
                                    text:       qsTr("Enable PID Flow Control")
                                    fact:       _tankPIDEnable
                                }

                                QGCLabel {
                                    text:       qsTr("SPRAY_PID_EN parameter not found")
                                    visible:    !_tankPIDEnableAvailable
                                    color:      qgcPal.colorOrange
                                    font.pointSize: ScreenTools.smallFontPointSize
                                }
                            }
                        }

                        // D Flow parameter
                        RowLayout {
                            spacing: _margins
                            Layout.fillWidth: true

                            QGCLabel {
                                text:       qsTr("SPRAY_D_FLOW")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: _margins

                                FactTextField {
                                    Layout.fillWidth:   true
                                    fact:               _tankDFlow
                                    showUnits:          true
                                    inputMethodHints:   Qt.ImhFormattedNumbersOnly
                                    validator:          DoubleValidator { bottom: 0; decimals: 2 }
                                }

                                QGCLabel {
                                    text:       qsTr("SPRAY_D_FLOW parameter not found")
                                    visible:    !_tankDFlowAvailable
                                    color:      qgcPal.colorOrange
                                    font.pointSize: ScreenTools.smallFontPointSize
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}