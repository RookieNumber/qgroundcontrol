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

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

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

    // Liquid usage properties
    property var _tankCapacityParam: _activeVehicle && _activeVehicle.parameterManager ? _activeVehicle.parameterManager.getParameter(-1, "BATT2_CAPACITY") : null
    property real _tankCapacityML: _tankCapacityParam && !isNaN(_tankCapacityParam.rawValue) ? Number(_tankCapacityParam.rawValue) : NaN
    property var _efiFactGroup: _activeVehicle ? _activeVehicle.efi : null
    property real _fuelConsumedML: _efiFactGroup && !isNaN(_efiFactGroup.fuelConsumed.rawValue) ? 
        Number(_efiFactGroup.fuelConsumed.rawValue) * 1000 : NaN  // Convert cm³ to mL
    property real _liquidRemainingML: {
        if (isNaN(_tankCapacityML) || isNaN(_fuelConsumedML)) return NaN
        return Math.max(0, _tankCapacityML - _fuelConsumedML)
    }
    property bool _showLiquidUsed: !isNaN(_fuelConsumedML)

    // Mission waypoint properties
    property var _missionController: missionController
    property int _totalWaypoints: _missionController ? _missionController.missionItemCount : 0
    property int _completedWaypoints: _missionController ? _missionController.currentMissionIndex : 0
    property bool _showWaypointInfo: _totalWaypoints > 0

    // Auto tlog download properties
    property var _logDownloadController: logDownloadController
    property bool _autoDownloadEnabled: true
    property bool _tlogDownloadStarted: false

    on_VehicleArmedChanged: {
        if (_vehicleArmed) {
            _vehicleWasArmed = true
            _vehicleWasInMissionFlightMode = _vehicleInMissionFlightMode
        } else {
            if (_showMissionCompleteDialog) {
                missionCompleteDialogComponent.createObject(mainWindow).open()
                // Start automatic tlog download
                if (_autoDownloadEnabled && !_tlogDownloadStarted) {
                    _startAutoTlogDownload()
                }
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

    Component {
        id: missionCompleteDialogComponent

        QGCPopupDialog {
            id:         missionCompleteDialog
            title:      qsTr("Flight Plan complete")
            buttons:    Dialog.Close

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
                    Layout.alignment:   Qt.AlignHCenter
                    text:               _tlogDownloadStarted ? qsTr("Downloading tlog...") : qsTr("Download tlog")
                    enabled:            !_tlogDownloadStarted
                    visible:            _logDownloadController && !_tlogDownloadStarted
                    onClicked:          _startAutoTlogDownload()
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

                Rectangle {
                    Layout.fillWidth:   true
                    color:              qgcPal.text
                    height:             1
                    visible:            _showWaypointInfo
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

                 // Tlog download status
                 RowLayout {
                     Layout.fillWidth:       true
                     Layout.alignment:       Qt.AlignHCenter
                     spacing:                ScreenTools.defaultFontPixelWidth
                     visible:                _tlogDownloadStarted

                     QGCColoredImage {
                         width:              ScreenTools.defaultFontPixelHeight
                         height:             width
                         sourceSize.width:   width
                         source:             '/qmlimages/download.svg'
                         fillMode:           Image.PreserveAspectFit
                         color:              _logDownloadController && _logDownloadController.downloadingLogs ? qgcPal.colorOrange : qgcPal.colorGreen
                     }

                     QGCLabel {
                         text:               _logDownloadController && _logDownloadController.downloadingLogs ? 
                                             qsTr("Downloading tlog...") : qsTr("Tlog download completed")
                         horizontalAlignment: Text.AlignHCenter
                         color:              _logDownloadController && _logDownloadController.downloadingLogs ? qgcPal.colorOrange : qgcPal.colorGreen
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

                QGCLabel {
                    Layout.fillWidth:   true
                    wrapMode:           Text.WordWrap
                    color:              qgcPal.warningText
                    text:               qsTr("If you are changing batteries for Resume Mission do not disconnect from the vehicle.")
                    visible:            globals.guidedControllerFlyView.showResumeMission
                }
            }
        }
    }

    // Debug function to show mission complete dialog
    function showDebugMissionCompleteDialog() {
        missionCompleteDialogComponent.createObject(mainWindow).open()
    }

    // Format liquid used for display
    function _formatLiquidUsed() {
        if (isNaN(_fuelConsumedML)) return "N/A"
        if (_fuelConsumedML >= 1000) return ((_fuelConsumedML / 1000).toFixed(1) + " L")
        return Math.round(_fuelConsumedML) + " mL"
    }

    // Format liquid remaining for display
    function _formatLiquidRemaining() {
        if (isNaN(_liquidRemainingML)) return "N/A"
        if (_liquidRemainingML >= 1000) return ((_liquidRemainingML / 1000).toFixed(1) + " L")
        return Math.round(_liquidRemainingML) + " mL"
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
