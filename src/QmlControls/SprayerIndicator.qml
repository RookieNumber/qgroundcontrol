/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette
import MAVLink

//-------------------------------------------------------------------------
//-- Sprayer Indicator

Item {
    id:             _root
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          sprayerIndicatorRow.width
    
    property bool showIndicator: true
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    // Tank capacity (mL) sourced from parameter BATT2_CAPACITY
    property var _tankCapacityParam: _activeVehicle && _activeVehicle.parameterManager ? _activeVehicle.parameterManager.getParameter(-1, "BATT2_CAPACITY") : null
    property real _tankCapacityML: _tankCapacityParam && !isNaN(_tankCapacityParam.rawValue) ? Number(_tankCapacityParam.rawValue) : NaN

    // EFI data for flow rate and consumption
    property var _efiFactGroup: _activeVehicle ? _activeVehicle.efi : null
    property real _fuelConsumedML: _efiFactGroup && !isNaN(_efiFactGroup.fuelConsumed.rawValue) ? 
        Number(_efiFactGroup.fuelConsumed.rawValue) * 1000 : NaN  // Convert cm³ to mL
    property real _fuelFlowMLPerMin: _efiFactGroup && !isNaN(_efiFactGroup.fuelFlow.rawValue) ? 
        Number(_efiFactGroup.fuelFlow.rawValue) * 1000 : NaN  // Convert cm³/min to mL/min

    // Calculated values
    property real _liquidRemainingML: {
        if (isNaN(_tankCapacityML) || isNaN(_fuelConsumedML)) return NaN
        return Math.max(0, _tankCapacityML - _fuelConsumedML)
    }
    
    property real _liquidUsedML: {
        if (isNaN(_fuelConsumedML)) return NaN
        return _fuelConsumedML
    }

    // Check if spraying system is enabled
    property bool _sprayingEnabled: {
        if (_activeVehicle && _activeVehicle.parameterManager) {
            var sprayEnable = _activeVehicle.parameterManager.getParameter(-1, "SPRAY_ENABLE")
            if (sprayEnable) {
                return sprayEnable.rawValue !== 0
            }
        }
        return false
    }

    // Battery RTL monitoring
    property real _rtlBatteryThreshold: {
        // Try to get threshold from parameter, default to 20%
        if (_activeVehicle && _activeVehicle.parameterManager) {
            var rtlThreshold = _activeVehicle.parameterManager.getParameter(-1, "SPRAY_RTL_THRESHOLD")
            if (rtlThreshold && !isNaN(rtlThreshold.rawValue)) {
                return Number(rtlThreshold.rawValue)
            }
        }
        return 20.0  // Default 20% threshold
    }
    property bool _rtlTriggered: false
    property bool _vehicleArmed: _activeVehicle ? _activeVehicle.armed : false

    // Monitor battery capacity and trigger RTL when threshold is reached
    on_LiquidRemainingMLChanged: {
        if (_activeVehicle && _vehicleArmed && !_rtlTriggered && !isNaN(_tankCapacityML) && !isNaN(_liquidRemainingML)) {
            var batteryPercent = (_liquidRemainingML / _tankCapacityML) * 100
            if (batteryPercent <= _rtlBatteryThreshold) {
                _triggerRTL()
            }
        }
    }

    // Reset RTL trigger when vehicle is disarmed
    on_VehicleArmedChanged: {
        if (!_vehicleArmed) {
            _rtlTriggered = false
        }
    }

    function _triggerRTL() {
        if (_activeVehicle && _vehicleArmed && !_rtlTriggered) {
            _rtlTriggered = true
            _activeVehicle.guidedModeRTL(false)  // Use regular RTL, not smart RTL
            console.log("Battery RTL triggered at", _liquidRemainingML, "mL remaining")
        }
    }

    visible: showIndicator

    Row {
        id:             sprayerIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth / 2

        Loader {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            sourceComponent:    sprayerVisual
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showIndicatorDrawer(sprayerPopup, _root)
        }
    }

    Component {
        id: sprayerVisual

        Row {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            spacing:        ScreenTools.defaultFontPixelWidth / 2

            function getSprayerColor() {
                if (isNaN(_tankCapacityML) || isNaN(_liquidRemainingML)) return qgcPal.text
                
                // Color based on remaining capacity
                var percentRemaining = (_liquidRemainingML / _tankCapacityML) * 100
                if (percentRemaining > 50) {
                    return qgcPal.colorGreen
                } else if (percentRemaining > 20) {
                    return qgcPal.colorOrange
                } else {
                    return qgcPal.colorRed
                }
            }

            function _formatML(value) {
                if (isNaN(value)) return "N/A"
                if (value >= 1000) return (value / 1000).toFixed(1) + qsTr(" L")
                return Math.round(value) + qsTr(" mL")
            }

            function _formatFlowRate(value) {
                if (isNaN(value)) return "N/A"
                if (value >= 1000) return (value / 1000).toFixed(1) + qsTr(" L/min")
                return Math.round(value) + qsTr(" mL/min")
            }

            function _liquidRemainingML() {
                return _liquidRemainingML
            }

            function _liquidConsumedML() {
                return _liquidUsedML
            }

            function getSprayerConsumedText() {
                var consumed = _liquidConsumedML()
                if (!isNaN(consumed)) return _formatML(consumed)
                return "--"
            }

            function getSprayerRemainingText() {
                var remaining = _liquidRemainingML()
                if (!isNaN(remaining)) {
                    return qsTr("Remaining: ") + _formatML(remaining)
                }
                return ""
            }

            QGCColoredImage {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                width:              height
                sourceSize.width:   width
                source:             '/qmlimages/liquid.svg'
                fillMode:           Image.PreserveAspectFit
                color:              getSprayerColor()
            }

            QGCLabel {
                text:                   getSprayerConsumedText()
                font.pointSize:         ScreenTools.mediumFontPointSize
                color:                  getSprayerColor()
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Component {
        id: sprayerValuesAvailableComponent

        QtObject {
            property bool tankCapacityAvailable:    !isNaN(_tankCapacityML)
            property bool fuelConsumedAvailable:    !isNaN(_fuelConsumedML)
            property bool fuelFlowAvailable:        !isNaN(_fuelFlowMLPerMin)
            property bool liquidRemainingAvailable: !isNaN(_liquidRemainingML)
            property bool liquidUsedAvailable:      !isNaN(_liquidUsedML)
        }
    }

    Component {
        id: sprayerPopup

        ToolIndicatorPage {
            showExpand:         false
            contentComponent:   sprayerContentComponent
        }
    }
    
    Component {
        id: sprayerContentComponent
        
        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight

            QGCLabel {
                Layout.alignment:   Qt.AlignCenter
                text:               qsTr("Sprayer Status")
                font.family:        ScreenTools.demiboldFontFamily
            }

            // RTL Status Indicator
            RowLayout {
                Layout.fillWidth:   true
                Layout.alignment:   Qt.AlignHCenter
                spacing:            ScreenTools.defaultFontPixelWidth
                visible:            _rtlTriggered

                QGCColoredImage {
                    width:              ScreenTools.defaultFontPixelHeight
                    height:             width
                    sourceSize.width:   width
                    source:             '/qmlimages/ArrowUp.svg'
                    fillMode:           Image.PreserveAspectFit
                    color:              qgcPal.colorOrange
                }

                QGCLabel {
                    text:               qsTr("RTL Triggered - Low Battery")
                    color:              qgcPal.colorOrange
                    font.family:        ScreenTools.demiboldFontFamily
                }
            }

            RowLayout {
                    spacing: ScreenTools.defaultFontPixelWidth

                    ColumnLayout {
                        spacing: 0

                        property var sprayerValuesAvailable: sprayerValuesAvailableLoader.item

                        Loader {
                            id:                 sprayerValuesAvailableLoader
                            sourceComponent:    sprayerValuesAvailableComponent
                        }

                        QGCLabel { text: qsTr("Tank Capacity"); visible: sprayerValuesAvailable.tankCapacityAvailable }
                        QGCLabel { text: qsTr("Remaining"); visible: sprayerValuesAvailable.liquidRemainingAvailable }
                        QGCLabel { text: qsTr("Consumed"); visible: sprayerValuesAvailable.liquidUsedAvailable }
                        QGCLabel { text: qsTr("Flow Rate"); visible: sprayerValuesAvailable.fuelFlowAvailable }
                    }

                    ColumnLayout {
                        spacing: 0

                        property var sprayerValuesAvailable: sprayerValuesAvailableLoader.item

                        QGCLabel { 
                            text: !isNaN(_tankCapacityML) ? _formatML(_tankCapacityML) : "N/A"
                            visible: sprayerValuesAvailable.tankCapacityAvailable 
                        }
                        QGCLabel {
                            text: !isNaN(_liquidRemainingML) ? _formatML(_liquidRemainingML) : "N/A"
                            visible: sprayerValuesAvailable.liquidRemainingAvailable
                        }
                        QGCLabel {
                            text: !isNaN(_liquidUsedML) ? _formatML(_liquidUsedML) : "N/A"
                            visible: sprayerValuesAvailable.liquidUsedAvailable
                        }
                        QGCLabel { 
                            text: _formatFlowRate(_fuelFlowMLPerMin)
                            visible: sprayerValuesAvailable.fuelFlowAvailable 
                        }
                        QGCLabel { 
                            text: qsTr("Battery %")
                            visible: !isNaN(_tankCapacityML) && !isNaN(_liquidRemainingML)
                        }
                        QGCLabel { 
                            text: !isNaN(_tankCapacityML) && !isNaN(_liquidRemainingML) ? 
                                  Math.round((_liquidRemainingML / _tankCapacityML) * 100) + "%" : "N/A"
                            visible: !isNaN(_tankCapacityML) && !isNaN(_liquidRemainingML)
                            color: !isNaN(_tankCapacityML) && !isNaN(_liquidRemainingML) && 
                                   ((_liquidRemainingML / _tankCapacityML) * 100) <= _rtlBatteryThreshold ? 
                                   qgcPal.colorOrange : qgcPal.text
                        }
                        QGCLabel { 
                            text: qsTr("RTL Threshold")
                            visible: true
                        }
                        QGCLabel { 
                            text: _rtlBatteryThreshold + "%"
                            visible: true
                        }
                    }
                }
        }
    }
}