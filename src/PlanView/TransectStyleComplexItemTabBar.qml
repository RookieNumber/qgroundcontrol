import QtQuick                      2.3

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0

QGCTabBar {
    id: tabBar

    // Mission item used to tailor which tabs are shown
    property var missionItem
    readonly property bool isSpraying: missionItem && missionItem.patternName === qsTr("Spraying")

    // Hide the entire tab bar when spraying (no tabs visible)
    visible: !isSpraying

    Component.onCompleted: currentIndex = isSpraying ? 0 : (QGroundControl.settingsManager.planViewSettings.displayPresetsTabFirst.rawValue ? 2 : 0)
    onIsSprayingChanged: if (isSpraying) currentIndex = 0

    QGCTabButton { icon.source: "/qmlimages/PatternGrid.png"; icon.height: ScreenTools.defaultFontPixelHeight; visible: !isSpraying }
    QGCTabButton { icon.source: "/qmlimages/PatternCamera.png"; icon.height: ScreenTools.defaultFontPixelHeight; visible: !isSpraying }
    QGCTabButton { icon.source: "/qmlimages/PatternTerrain.png"; icon.height: ScreenTools.defaultFontPixelHeight; visible: !isSpraying }
    QGCTabButton { icon.source: "/qmlimages/PatternPresets.png"; icon.height: ScreenTools.defaultFontPixelHeight; visible: !isSpraying }
}
