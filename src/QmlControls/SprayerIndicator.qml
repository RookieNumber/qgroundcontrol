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

    // Find sprayer battery - look for secondary battery (ID = 2) or any battery with sprayer function
    property var _sprayerBattery: {
        if (_activeVehicle && _activeVehicle.batteries) {
            // First try to find battery with sprayer function
            for (var i = 0; i < _activeVehicle.batteries.count; i++) {
                var battery = _activeVehicle.batteries.get(i)
                if (battery.function && battery.function.rawValue === MAVLink.MAV_BATTERY_FUNCTION_PROPULSION) {
                    return battery
                }
            }
            // If no sprayer function battery found, look for secondary battery (ID = 2)
            for (var j = 0; j < _activeVehicle.batteries.count; j++) {
                var battery2 = _activeVehicle.batteries.get(j)
                if (battery2.id.rawValue === 2) {
                    return battery2
                }
            }
            // Fallback: look for any battery that's not the main battery (ID = 1)
            for (var k = 0; k < _activeVehicle.batteries.count; k++) {
                var battery3 = _activeVehicle.batteries.get(k)
                if (battery3.id.rawValue !== 1) {
                    return battery3
                }
            }
            // If no secondary battery, use the main battery
            if (_activeVehicle.batteries.count > 0) {
                return _activeVehicle.batteries.get(0)
            }
        }
        return null
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
            property var sprayer: _sprayerBattery
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
                if (!sprayer) return qgcPal.text
                
                // Color based on remaining capacity
                var percentRemaining = sprayer.percentRemaining.rawValue
                if (isNaN(percentRemaining)) {
                    return qgcPal.text
                }
                
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

            function _liquidRemainingML() {
                if (!sprayer || isNaN(_tankCapacityML)) return NaN
                var percent = sprayer.percentRemaining && !isNaN(sprayer.percentRemaining.rawValue) ? sprayer.percentRemaining.rawValue : NaN
                if (isNaN(percent)) return NaN
                var remaining = _tankCapacityML * Math.max(0, Math.min(100, percent)) / 100.0
                return remaining
            }

            function _liquidConsumedML() {
                if (isNaN(_tankCapacityML)) return NaN
                var remaining = _liquidRemainingML()
                if (isNaN(remaining)) return NaN
                var consumed = _tankCapacityML - remaining
                if (consumed < 0) consumed = 0
                return consumed
            }

            function getSprayerConsumedText() {
                if (!sprayer) return "--"
                var consumed = _liquidConsumedML()
                if (!isNaN(consumed)) return _formatML(consumed)
                // Fallbacks
                if (sprayer.percentRemaining && !isNaN(sprayer.percentRemaining.rawValue)) {
                    if (sprayer.percentRemaining.rawValue > 98.9) {
                        return qsTr("100%")
                    }
                    return sprayer.percentRemaining.valueString + sprayer.percentRemaining.units
                }
                return "--"
            }

            function getSprayerRemainingText() {
                if (!sprayer) return ""
                var remaining = _liquidRemainingML()
                if (!isNaN(remaining)) {
                    return qsTr("Remaining: ") + _formatML(remaining)
                }
                if (sprayer.percentRemaining && !isNaN(sprayer.percentRemaining.rawValue)) {
                    return qsTr("Remaining: ") + sprayer.percentRemaining.valueString + sprayer.percentRemaining.units
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
            property bool functionAvailable:        sprayer && sprayer.function.rawValue !== MAVLink.MAV_BATTERY_FUNCTION_UNKNOWN
            property bool temperatureAvailable:     sprayer && !isNaN(sprayer.temperature.rawValue)
            property bool currentAvailable:         sprayer && !isNaN(sprayer.current.rawValue)
            property bool mahConsumedAvailable:     sprayer && !isNaN(sprayer.mahConsumed.rawValue)
            property bool timeRemainingAvailable:   sprayer && !isNaN(sprayer.timeRemaining.rawValue)
            property bool chargeStateAvailable:     sprayer && sprayer.chargeState.rawValue !== MAVLink.MAV_BATTERY_CHARGE_STATE_UNDEFINED
            property bool percentRemainingAvailable: sprayer && !isNaN(sprayer.percentRemaining.rawValue)
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

            RowLayout {
                    spacing: ScreenTools.defaultFontPixelWidth

                    ColumnLayout {
                        spacing: 0

                        property var sprayerValuesAvailable: sprayerValuesAvailableLoader.item

                        Loader {
                            id:                 sprayerValuesAvailableLoader
                            sourceComponent:    sprayerValuesAvailableComponent
                            property var sprayer: _sprayerBattery
                        }

                        QGCLabel { text: qsTr("Liquid") }
                        QGCLabel { text: qsTr("Remaining"); visible: sprayerValuesAvailable.percentRemainingAvailable }
                        QGCLabel { text: qsTr("Consumed"); visible: sprayerValuesAvailable.mahConsumedAvailable }
                        QGCLabel { text: qsTr("Temperature"); visible: sprayerValuesAvailable.temperatureAvailable }
                        QGCLabel { text: qsTr("Function"); visible: sprayerValuesAvailable.functionAvailable }
                        QGCLabel { text: qsTr("Status"); visible: sprayerValuesAvailable.chargeStateAvailable }
                    }

                    ColumnLayout {
                        spacing: 0

                        property var sprayerValuesAvailable: sprayerValuesAvailableLoader.item

                        QGCLabel { text: "" }
                        QGCLabel {
                            text: !isNaN(_liquidRemainingML()) ? _formatML(_liquidRemainingML()) : (_sprayerBattery ? _sprayerBattery.percentRemaining.valueString + " " + _sprayerBattery.percentRemaining.units : "N/A")
                            visible: sprayerValuesAvailable.percentRemainingAvailable || !isNaN(_liquidRemainingML())
                        }
                        QGCLabel {
                            text: !isNaN(_liquidConsumedML()) ? _formatML(_liquidConsumedML()) : (_sprayerBattery && _sprayerBattery.mahConsumed ? _sprayerBattery.mahConsumed.valueString + " " + qsTr("mAh") : "N/A")
                            visible: !isNaN(_liquidConsumedML()) || sprayerValuesAvailable.mahConsumedAvailable
                        }
                        QGCLabel { 
                            text: _sprayerBattery ? _sprayerBattery.temperature.valueString + " " + _sprayerBattery.temperature.units : "N/A"
                            visible: sprayerValuesAvailable.temperatureAvailable 
                        }
                        QGCLabel { 
                            text: _sprayerBattery ? _sprayerBattery.function.enumStringValue : "N/A"
                            visible: sprayerValuesAvailable.functionAvailable 
                        }
                        QGCLabel { 
                            text: _sprayerBattery ? _sprayerBattery.chargeState.enumStringValue : "N/A"
                            visible: sprayerValuesAvailable.chargeStateAvailable 
                        }
                    }
                }
        }
    }
}