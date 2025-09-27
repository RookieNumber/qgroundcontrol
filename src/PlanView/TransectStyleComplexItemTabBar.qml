import QtQuick                      2.3

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0

QGCTabBar {
    id: tabBar

    // Allow callers to override which tab is selected at startup
    property int initialIndexOverride: -1
    // Allow callers to control visibility of specific tabs
    property bool showCameraTab:  true
    property bool showTerrainTab: true
    property bool showPresetsTab: true

    Component.onCompleted: currentIndex = initialIndexOverride >= 0 ? initialIndexOverride : (QGroundControl.settingsManager.planViewSettings.displayPresetsTabFirst.rawValue ? 2 : 0)

    QGCTabButton { icon.source: "/qmlimages/PatternGrid.png"; icon.height: ScreenTools.defaultFontPixelHeight }
    QGCTabButton { icon.source: "/qmlimages/PatternCamera.png";  icon.height: ScreenTools.defaultFontPixelHeight; visible: showCameraTab }
    QGCTabButton { icon.source: "/qmlimages/PatternTerrain.png"; icon.height: ScreenTools.defaultFontPixelHeight; visible: showTerrainTab }
    QGCTabButton { icon.source: "/qmlimages/PatternPresets.png"; icon.height: ScreenTools.defaultFontPixelHeight; visible: showPresetsTab }
}
