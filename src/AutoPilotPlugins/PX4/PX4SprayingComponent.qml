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
            
            // PX4 spraying parameters (these would need to be defined in PX4 firmware)
            // For now, we'll use generic parameter names that can be customized
            property Fact _sprayEnable:             controller.getParameterFact(-1, "SPRAY_ENABLE", false /* reportMissing */)
            property Fact _tankCapacity:            controller.getParameterFact(-1, "SPRAY_TANK_CAP", false /* reportMissing */)
            property Fact _flowRate:                controller.getParameterFact(-1, "SPRAY_FLOW_RATE", false /* reportMissing */)
            property Fact _pumpPWM:                 controller.getParameterFact(-1, "SPRAY_PUMP_PWM", false /* reportMissing */)
            property Fact _tankLow:                 controller.getParameterFact(-1, "SPRAY_TANK_LOW", false /* reportMissing */)

            // Parameter availability checks
            property bool _sprayEnableAvailable:    controller.parameterExists(-1, "SPRAY_ENABLE")
            property bool _tankCapacityAvailable:   controller.parameterExists(-1, "SPRAY_TANK_CAP")
            property bool _flowRateAvailable:       controller.parameterExists(-1, "SPRAY_FLOW_RATE")
            property bool _pumpPWMAvailable:        controller.parameterExists(-1, "SPRAY_PUMP_PWM")
            property bool _tankLowAvailable:        controller.parameterExists(-1, "SPRAY_TANK_LOW")

            // State properties
            property bool _sprayEnabled:            _sprayEnableAvailable && _sprayEnable.rawValue !== 0

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            // Debug message when spraying parameters are not available
            Column {
                spacing: _margins
                visible: !_sprayEnableAvailable
                width: parent.width

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       qsTr("DEBUG MODE: Spraying system parameters are not available on this vehicle. The vehicle firmware may not support spraying or the required parameters are missing. This component is shown for debugging purposes.")
                    font.pointSize: ScreenTools.mediumFontPointSize
                    color:      qgcPal.colorOrange
                }
            }

            // Spraying System Enable/Disable
            SettingsGroupLayout {
                Layout.fillWidth:   true
                heading:            qsTr("Spraying System") + (_sprayEnableAvailable ? "" : " (DEBUG - Parameter Not Available)")
                visible:            true  // Always visible for debug

                FactCheckBox {
                    text:       qsTr("Enable Spraying System")
                    fact:       _sprayEnable
                    visible:    _sprayEnableAvailable
                    enabled:    _sprayEnableAvailable
                }
                
                QGCLabel {
                    text:       qsTr("SPRAY_ENABLE parameter not found in vehicle")
                    visible:    !_sprayEnableAvailable
                    color:      qgcPal.colorOrange
                }
            }

            // Tank Configuration
            SettingsGroupLayout {
                Layout.fillWidth:   true
                heading:            qsTr("Tank Configuration") + (!_sprayEnableAvailable ? " (DEBUG)" : "")
                visible:            !_sprayEnableAvailable || (_sprayEnableAvailable && _sprayEnabled)

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               _tankCapacity
                    visible:            _tankCapacityAvailable
                    enabled:            _tankCapacityAvailable
                }
                
                QGCLabel {
                    text:       qsTr("SPRAY_TANK_CAP parameter not found")
                    visible:    !_tankCapacityAvailable && !_sprayEnableAvailable
                    color:      qgcPal.colorOrange
                }

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               _tankLow
                    visible:            _tankLowAvailable
                    enabled:            _tankLowAvailable
                }
                
                QGCLabel {
                    text:       qsTr("SPRAY_TANK_LOW parameter not found")
                    visible:    !_tankLowAvailable && !_sprayEnableAvailable
                    color:      qgcPal.colorOrange
                }
            }

            // Flow Control Configuration
            SettingsGroupLayout {
                Layout.fillWidth:   true
                heading:            qsTr("Flow Control") + (!_sprayEnableAvailable ? " (DEBUG)" : "")
                visible:            !_sprayEnableAvailable || (_sprayEnableAvailable && _sprayEnabled)

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               _flowRate
                    visible:            _flowRateAvailable
                    enabled:            _flowRateAvailable
                }
                
                QGCLabel {
                    text:       qsTr("SPRAY_FLOW_RATE parameter not found")
                    visible:    !_flowRateAvailable && !_sprayEnableAvailable
                    color:      qgcPal.colorOrange
                }

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               _pumpPWM
                    visible:            _pumpPWMAvailable
                    enabled:            _pumpPWMAvailable
                }
                
                QGCLabel {
                    text:       qsTr("SPRAY_PUMP_PWM parameter not found")
                    visible:    !_pumpPWMAvailable && !_sprayEnableAvailable
                    color:      qgcPal.colorOrange
                }
            }
        }
    }
}

