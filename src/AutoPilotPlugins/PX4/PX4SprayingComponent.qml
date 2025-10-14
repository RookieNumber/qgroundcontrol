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

            // Contain property for frogs custom parameters
            property Fact _tankcFull:              controller.getParameterFact(-1, "TANK_C_FULL", false /* reportMissing */)
            property Fact _tankFull:               controller.getParameterFact(-1, "TANK_FULL", false /* reportMissing */)
            property Fact _tankIFlow:              controller.getParameterFact(-1, "TANK_I_FLOW", false /* reportMissing */)
            property Fact _tankPFlow:              controller.getParameterFact(-1, "TANK_P_FLOW", false /* reportMissing */)
            property Fact _tankMaxFlow:            controller.getParameterFact(-1, "TANK_MAX_FLOW", false /* reportMissing */)
            property Fact _tankSetFlow:            controller.getParameterFact(-1, "TANK_SET_FLOW", false /* reportMissing */)
            property Fact _tankTRt:                controller.getParameterFact(-1, "TANK_T_RTL", false /* reportMissing */)


            // Contain paramter availability checks
            property bool _tankcFullAvailable:       controller.parameterExists(-1, "TANK_C_FULL")
            property bool _tankFullAvailable:        controller.parameterExists(-1, "TANK_FULL")
            property bool _tankIFlowAvailable:       controller.parameterExists(-1, "TANK_I_FLOW")
            property bool _tankPFlowAvailable:       controller.parameterExists(-1, "TANK_P_FLOW")
            property bool _tankMaxFlowAvailable:     controller.parameterExists(-1, "TANK_MAX_FLOW")
            property bool _tankSetFlowAvailable:     controller.parameterExists(-1, "TANK_SET_FLOW")
            property bool _tankTRtAvailable:         controller.parameterExists(-1, "TANK_T_RTL")

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            // Debug message when spraying parameters are not available
            Column {
                spacing: _margins
                visible: !_tankSetFlowAvailable
                width: parent.width

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       qsTr("DEBUG MODE: Spraying system parameters are not available on this vehicle. The vehicle firmware may not support spraying or the required parameters are missing. This component is shown for debugging purposes.")
                    font.pointSize: ScreenTools.mediumFontPointSize
                    color:      qgcPal.colorOrange
                }
            }

            // Tank Configuration
            SettingsGroupLayout {
                Layout.fillWidth:   true
                heading:            qsTr("Tank Configuration") + (!_tankFullAvailable ? " (DEBUG)" : "")
                visible:            true

                RowLayout {
                    spacing: _margins
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    QGCLabel {
                        text:       qsTr("TANK_C_FULL")
                        visible:    true
                    }

                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: _margins

                        FactTextField {
                            Layout.fillWidth:   true
                            fact:               QGroundControl.settingsManager.px4SprayingComponent.TANK_C_FULL
                            visible:            true
                            enabled:            true
                            showUnits:          true
                            inputMethodHints:   Qt.ImhFormattedNumbersOnly
                            validator:          DoubleValidator { bottom: 0; decimals: 2 }
                        }

                        QGCLabel {
                            text:       qsTr("TANK_C_FULL parameter not found")
                            visible:    !_tankcFullAvailable
                            color:      qgcPal.colorOrange
                            font.pointSize: ScreenTools.smallFontPointSize
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: _margins

                    QGCLabel {
                        text:       qsTr("TANK_FULL")
                        visible:    true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: _margins
    
                        FactTextField {
                            Layout.fillWidth:   true
                            fact:               _tankFull
                            visible:            true
                            enabled:            true
                            showUnits:          true
                            inputMethodHints:   Qt.ImhFormattedNumbersOnly
                            validator:          DoubleValidator { bottom: 0; decimals: 2 }
                        }

                        QGCLabel {
                            text:       qsTr("TANK_FULL parameter not found")
                            visible:    !_tankFullAvailable
                            color:      qgcPal.colorOrange
                            font.pointSize: ScreenTools.smallFontPointSize
                        }
                    }
                }

                RowLayout {
                    spacing: _margins
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    QGCLabel {
                        text:       qsTr("TANK_I_FLOW")
                        visible:    true
                    }

                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: _margins

                        FactTextField {
                            Layout.fillWidth:   true
                            fact:               _tankIFlow
                            visible:            true
                            enabled:            true
                            showUnits:          true
                            inputMethodHints:   Qt.ImhFormattedNumbersOnly
                            validator:          DoubleValidator { bottom: 0; decimals: 2 }
                        }

                        QGCLabel {
                            text:       qsTr("TANK_I_FLOW parameter not found")
                            visible:    !_tankIFlowAvailable
                            color:      qgcPal.colorOrange
                            font.pointSize: ScreenTools.smallFontPointSize
                        }
                    }
                }

                RowLayout {
                    spacing: _margins
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    QGCLabel {
                        text:       qsTr("TANK_P_FLOW")
                        visible:    true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: _margins

                        FactTextField {
                            Layout.fillWidth:   true
                            fact:               _tankPFlow
                            visible:            true
                            enabled:            true
                            showUnits:          true
                            inputMethodHints:   Qt.ImhFormattedNumbersOnly
                            validator:          DoubleValidator { bottom: 0; decimals: 2 }
                        }

                        QGCLabel {
                            text:       qsTr("TANK_P_FLOW parameter not found")
                            visible:    !_tankPFlowAvailable
                            color:      qgcPal.colorOrange
                            font.pointSize: ScreenTools.smallFontPointSize
                        }
                    }
                }
            }

            // Flow Control Configuration
            SettingsGroupLayout {
                Layout.fillWidth:   true
                heading:            qsTr("Flow Control") + (!_tankSetFlowAvailable ? " (DEBUG)" : "")
                visible:            true

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: _margins

                    QGCLabel {
                        text:       qsTr("TANK_SET_FLOW")
                        visible:    true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: _margins
                     

                        FactTextField {
                            Layout.fillWidth:   true
                            fact:               _tankSetFlow
                            visible:            true
                            enabled:            true
                            showUnits:          true
                            inputMethodHints:   Qt.ImhFormattedNumbersOnly
                            validator:          DoubleValidator { bottom: 0; decimals: 2 }
                        }

                        QGCLabel {
                            text:       qsTr("TANK_SET_FLOW parameter not found")
                            visible:    !_tankSetFlowAvailable
                            color:      qgcPal.colorOrange
                            font.pointSize: ScreenTools.smallFontPointSize
                        }
                    }
                }

                RowLayout {
                    spacing: _margins
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    QGCLabel {
                        text:       qsTr("TANK_MAX_FLOW")
                        visible:    true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: _margins

                        FactTextField {
                            Layout.fillWidth:   true
                            fact:               _tankMaxFlow
                            visible:            true
                            enabled:            true
                            showUnits:          true
                            inputMethodHints:   Qt.ImhFormattedNumbersOnly
                            validator:          DoubleValidator { bottom: 0; decimals: 2 }
                        }

                        QGCLabel {
                            text:       qsTr("TANK_MAX_FLOW parameter not found")
                            visible:    !_tankMaxFlowAvailable
                            color:      qgcPal.colorOrange
                            font.pointSize: ScreenTools.smallFontPointSize
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: _margins

                    QGCLabel {
                        text:       qsTr("TANK_T_RTL")
                        visible:    true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: _margins

                        FactTextField {
                            Layout.fillWidth:   true
                            fact:               _tankTRt
                            visible:            true
                            enabled:            true
                            showUnits:          true
                            inputMethodHints:   Qt.ImhFormattedNumbersOnly
                            validator:          DoubleValidator { bottom: 0; decimals: 1 }
                        }

                        QGCLabel {
                            text:       qsTr("TANK_T_RTL parameter not found")
                            visible:    !_tankTRtAvailable
                            color:      qgcPal.colorOrange
                            font.pointSize: ScreenTools.smallFontPointSize
                        }
                    }
                }
            }
        }
    }
}

