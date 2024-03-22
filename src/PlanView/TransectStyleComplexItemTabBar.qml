import QtQuick                      2.3

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0

QGCTabBar {
    id: tabBar

    Component.onCompleted: currentIndex = QGroundControl.settingsManager.planViewSettings.displayPresetsTabFirst.rawValue ? 2 : 0

    QGCTabButton { icon.source: "/qmlimages/PatternGrid.png"; icon.height: ScreenTools.defaultFontPixelHeight }
//    QGCTabButton { icon.source: "/qmlimages/PatternCamera.png"; icon.height: ScreenTools.defaultFontPixelHeight }
    QGCTabButton { icon.source: "/qmlimages/PatternTerrain.png"; icon.height: ScreenTools.defaultFontPixelHeight
        onClicked: {
            var removeModes = []
            var updateFunction = function(altMode){ missionItem.cameraCalc.distanceMode = altMode }
            removeModes.push(QGroundControl.AltitudeModeMixed)
            if (!missionItem.masterController.controllerVehicle.supportsTerrainFrame) {
                removeModes.push(QGroundControl.AltitudeModeTerrainFrame)
            }
            if (!QGroundControl.corePlugin.options.showMissionAbsoluteAltitude || !_missionItem.cameraCalc.isManualCamera) {
                removeModes.push(QGroundControl.AltitudeModeAbsolute)
            }
            mainWindow.showPopupDialogFromComponent(altModeDialogComponent, { rgRemoveModes: removeModes, updateAltModeFn: updateFunction })
        }

        Component { id: altModeDialogComponent; AltModeDialog { } }
    }
//    QGCTabButton { icon.source: "/qmlimages/PatternPresets.png"; icon.height: ScreenTools.defaultFontPixelHeight }
}
