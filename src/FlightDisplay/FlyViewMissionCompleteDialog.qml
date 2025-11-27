/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Controls 2.4
import QtQuick.Dialogs  1.3
import QtQuick.Layouts  1.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import MAVLink                      1.0

/// Dialog which shows up when a flight completes. Prompts the user for things like whether they should remove the plan from the vehicle.
Item {
    visible: false

    property var missionController
    property var geoFenceController
    property var rallyPointController

    // The following code is used to track vehicle states for showing the mission complete dialog
    property var  _activeVehicle:                   QGroundControl.multiVehicleManager.activeVehicle
    property bool _vehicleArmed:                    _activeVehicle ? _activeVehicle.armed : true // true here prevents pop up from showing during shutdown
    property bool _vehicleWasArmed:                 false
    property bool _vehicleInMissionFlightMode:      _activeVehicle ? (_activeVehicle.flightMode === _activeVehicle.missionFlightMode) : false
    property bool _vehicleWasInMissionFlightMode:   false
    property bool _showMissionCompleteDialog:       _vehicleWasArmed && _vehicleWasInMissionFlightMode &&
                                                    (missionController.containsItems || geoFenceController.containsItems || rallyPointController.containsItems ||
                                                     (_activeVehicle ? _activeVehicle.cameraTriggerPoints.count !== 0 : false))

    // Spraying system properties
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
        }
        return null
    }

    // Tank capacity (mL) sourced from parameter BATT2_CAPACITY
    property var _tankCapacityParam: _activeVehicle && _activeVehicle.parameterManager ? _activeVehicle.parameterManager.getParameter(-1, "BATT2_CAPACITY") : null
    property real _tankCapacityML: _tankCapacityParam && !isNaN(_tankCapacityParam.rawValue) ? Number(_tankCapacityParam.rawValue) : NaN

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

    on_VehicleArmedChanged: {
        if (_vehicleArmed) {
            _vehicleWasArmed = true
            _vehicleWasInMissionFlightMode = _vehicleInMissionFlightMode
        } else {
            if (_showMissionCompleteDialog) {
                // Always trigger auto-download when mission completes
                _downloadFlightLogs()
                missionCompleteDialogComponent.createObject(mainWindow).open()
            }
            _vehicleWasArmed = false
            _vehicleWasInMissionFlightMode = false
        }
    }

    on_VehicleInMissionFlightModeChanged: {
        if (_vehicleInMissionFlightMode && _vehicleArmed) {
            _vehicleWasInMissionFlightMode = true
        }
    }

    // Function to download flight logs
    function _downloadFlightLogs() {
        if (_activeVehicle && _activeVehicle.logDownloadController && !_activeVehicle.logDownloadController.downloadingLogs) {
            // Get the default log save path
            var savePath = QGroundControl.settingsManager.appSettings.logSavePath
            
            // Start automatic download
            _activeVehicle.logDownloadController.download(savePath)
        }
    }

    // Liquid consumption calculation functions
    function _liquidRemainingML() {
        if (!_sprayerBattery || isNaN(_tankCapacityML)) return NaN
        var percent = _sprayerBattery.percentRemaining && !isNaN(_sprayerBattery.percentRemaining.rawValue) ? _sprayerBattery.percentRemaining.rawValue : NaN
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

    function _formatML(value) {
        if (isNaN(value)) return "N/A"
        if (value >= 1000) return (value / 1000).toFixed(1) + qsTr(" L")
        return Math.round(value) + qsTr(" mL")
    }

    function getLiquidUsedText() {
        if (!_sprayingEnabled || !_sprayerBattery) return ""
        var consumed = _liquidConsumedML()
        if (!isNaN(consumed)) return _formatML(consumed)
        // Fallback to percentage if available
        if (_sprayerBattery.percentRemaining && !isNaN(_sprayerBattery.percentRemaining.rawValue)) {
            var percentUsed = 100 - _sprayerBattery.percentRemaining.rawValue
            return percentUsed.toFixed(1) + "%"
        }
        return ""
    }

    // Function to show the dialog programmatically (for debugging)
    function showDialog() {
        missionCompleteDialogComponent.createObject(mainWindow).open()
    }

    // Properties for waypoint completion display
    property bool _showWaypointInfo: missionController && missionController.missionItemCount > 0
    property int _totalWaypoints: missionController ? missionController.missionItemCount : 0
    property int _completedWaypoints: {
        if (!_activeVehicle || !missionController) return 0
        // When mission is complete, currentMissionIndex should be at or past the last waypoint
        var currentIndex = missionController.currentMissionIndex
        // If vehicle is disarmed and was in mission mode, assume all waypoints completed
        if (!_vehicleArmed && _vehicleWasInMissionFlightMode) {
            return _totalWaypoints
        }
        // Otherwise return current index (which represents next waypoint, so completed = currentIndex)
        return currentIndex >= 0 ? currentIndex : 0
    }

    // Properties for liquid usage display
    property bool _showLiquidUsed: _sprayingEnabled && _sprayerBattery
    property real _fuelConsumedML: _liquidConsumedML()

    // Properties for log download
    property var _logDownloadController: _activeVehicle ? _activeVehicle.logDownloadController : null
    property bool _tlogDownloadStarted: false

    Component {
        id: missionCompleteDialogComponent

        QGCPopupDialog {
            id:         missionCompleteDialog
            title:      qsTr("Flight Plan complete")
            buttons:    StandardButton.Close

            property var activeVehicleCopy: _activeVehicle
            onActiveVehicleCopyChanged:
                if (!activeVehicleCopy) {
                    missionCompleteDialog.close()
                }

            ColumnLayout {
                id:         column
                width:      40 * ScreenTools.defaultFontPixelWidth
                spacing:    ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    Layout.fillWidth:       true
                    text:                   qsTr("%1 Images Taken").arg(_activeVehicle.cameraTriggerPoints.count)
                    horizontalAlignment:    Text.AlignHCenter
                    visible:                _activeVehicle.cameraTriggerPoints.count !== 0
                }

                QGCLabel {
                    Layout.fillWidth:       true
                    text:                   qsTr("Liquid Used: %1").arg(getLiquidUsedText())
                    horizontalAlignment:    Text.AlignHCenter
                    visible:                _sprayingEnabled && getLiquidUsedText() !== ""
                }

                QGCButton {
                    Layout.fillWidth:   true
                    text:               qsTr("Remove plan from vehicle")
                    visible:            !_activeVehicle.communicationLost// && !_activeVehicle.apmFirmware  // ArduPilot has a bug somewhere with mission clear
                    onClicked: {
                        _planController.removeAllFromVehicle()
                        missionCompleteDialog.close()
                    }
                }

                QGCButton {
                    Layout.fillWidth:   true
                    Layout.alignment:   Qt.AlignHCenter
                    text:               qsTr("Leave plan on vehicle")
                    onClicked:          missionCompleteDialog.close()

                }

                QGCButton {
                    Layout.fillWidth:   true
                    text:               qsTr("Download Flight Logs")
                    visible:            !_activeVehicle.communicationLost
                    onClicked: {
                        _downloadFlightLogs()
                        missionCompleteDialog.close()
                    }
                }

                Rectangle {
                    Layout.fillWidth:   true
                    color:              qgcPal.text
                    height:             1
                }

                ColumnLayout {
                    Layout.fillWidth:   true
                    spacing:            ScreenTools.defaultFontPixelHeight
                    visible:            !_activeVehicle.communicationLost && globals.guidedControllerFlyView.showResumeMission

                    QGCButton {
                        Layout.fillWidth:   true
                        Layout.alignment:   Qt.AlignHCenter
                        text:               qsTr("Resume Mission From Waypoint %1").arg(globals.guidedControllerFlyView._resumeMissionIndex)

                        onClicked: {
                            globals.guidedControllerFlyView.executeAction(globals.guidedControllerFlyView.actionResumeMission, null, null)
                            missionCompleteDialog.close()
                        }
                    }

                    QGCLabel {
                        Layout.fillWidth:   true
                        wrapMode:           Text.WordWrap
                        text:               qsTr("Resume Mission will rebuild the current mission from the last flown waypoint and upload it to the vehicle for the next flight.")
                    }
                }

                QGCLabel {
                    Layout.fillWidth:   true
                    wrapMode:           Text.WordWrap
                    color:              qgcPal.warningText
                    text:               qsTr("If you are changing batteries for Resume Mission do not disconnect from the vehicle.")
                    visible:            globals.guidedControllerFlyView.showResumeMission
                }

                // Waypoint completion information
                RowLayout {
                    Layout.fillWidth:       true
                    Layout.alignment:       Qt.AlignHCenter
                    spacing:                ScreenTools.defaultFontPixelWidth * 2
                    visible:                _showWaypointInfo

                    // Waypoint icon and completed count
                    RowLayout {
                        spacing:            ScreenTools.defaultFontPixelWidth / 2
                        
                        QGCColoredImage {
                            width:          ScreenTools.defaultFontPixelHeight
                            height:         width
                            sourceSize.width: width
                            source:         '/qmlimages/waypoint.svg'
                            fillMode:       Image.PreserveAspectFit
                            color:          qgcPal.colorGreen
                        }

                        QGCLabel {
                            text:           qsTr("Completed: %1/%2").arg(_completedWaypoints).arg(_totalWaypoints)
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    // Mission progress percentage
                    QGCLabel {
                        text:               qsTr("Progress: %1%").arg(_missionProgressPercent())
                        horizontalAlignment: Text.AlignHCenter
                        color:              qgcPal.colorGreen
                    }
                 }


                  // Liquid usage information side by side
                 RowLayout {
                     Layout.fillWidth:       true
                     Layout.alignment:       Qt.AlignHCenter
                     spacing:                ScreenTools.defaultFontPixelWidth * 2
                     visible:                _showLiquidUsed

                     // Liquid Used
                     RowLayout {
                         spacing:            ScreenTools.defaultFontPixelWidth / 2
                         
                         QGCColoredImage {
                             width:          ScreenTools.defaultFontPixelHeight
                             height:         width
                             sourceSize.width: width
                             source:         '/qmlimages/liquid.svg'
                             fillMode:       Image.PreserveAspectFit
                             color:          qgcPal.text
                         }

                         QGCLabel {
                             text:           qsTr("Used: %1").arg(_formatLiquidUsed())
                             horizontalAlignment: Text.AlignHCenter
                         }
                     }

                     // Liquid Remaining
                     RowLayout {
                         spacing:            ScreenTools.defaultFontPixelWidth / 2
                         
                         QGCColoredImage {
                             width:          ScreenTools.defaultFontPixelHeight
                             height:         width
                             sourceSize.width: width
                             source:         '/qmlimages/liquid.svg'
                             fillMode:       Image.PreserveAspectFit
                             color:          qgcPal.text
                         }

                         QGCLabel {
                             text:           qsTr("Remaining: %1").arg(_formatLiquidRemaining())
                             horizontalAlignment: Text.AlignHCenter
                         }
                     }
                 }



            }
        }
    }

    // Format liquid used for display
    function _formatLiquidUsed() {
        var consumed = _liquidConsumedML()
        if (isNaN(consumed)) return "N/A"
        if (consumed >= 1000) return ((consumed / 1000).toFixed(1) + qsTr(" L"))
        return Math.round(consumed) + qsTr(" mL")
    }

    // Format liquid remaining for display
    function _formatLiquidRemaining() {
        var remaining = _liquidRemainingML()
        if (isNaN(remaining)) return "N/A"
        if (remaining >= 1000) return ((remaining / 1000).toFixed(1) + qsTr(" L"))
        return Math.round(remaining) + qsTr(" mL")
    }

    // Calculate mission progress percentage
    function _missionProgressPercent() {
        if (_totalWaypoints <= 0) return 0
        return Math.round((_completedWaypoints / _totalWaypoints) * 100)
    }

    // Start automatic tlog download
    function _startAutoTlogDownload() {
        if (!_logDownloadController || _tlogDownloadStarted) return
        
        _tlogDownloadStarted = true
        
        // Refresh log list first, then download
        _logDownloadController.refresh()
        
        // Wait a moment for refresh to complete, then start download
        Qt.callLater(function() {
            if (_logDownloadController) {
                _logDownloadController.download()
            }
        })
    }
}