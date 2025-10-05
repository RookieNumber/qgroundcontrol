import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Controls

// Statistics section for TransectStyleComplexItems
Grid {
    // The following properties must be available up the hierarchy chain
    //property var    missionItem       ///< Mission Item for editor

    columns:        2
    columnSpacing:  ScreenTools.defaultFontPixelWidth

    QGCLabel { text: qsTr("Operations Area") }
    QGCLabel { text: QGroundControl.unitsConversion.squareMetersToAppSettingsAreaUnits(missionItem.coveredArea).toFixed(2) + " " + QGroundControl.unitsConversion.appSettingsAreaUnitsString }

   QGCLabel {
        text:       qsTr("Photo Count")
        visible:    missionItem.editorQml.indexOf("SprayingItemEditor.qml") === -1
    }
    QGCLabel {
        text:       missionItem.cameraShots
        visible:    missionItem.editorQml.indexOf("SprayingItemEditor.qml") === -1
    }
    QGCLabel {
        text:       qsTr("Photo Interval")
        visible:    missionItem.editorQml.indexOf("SprayingItemEditor.qml") === -1
    }
    QGCLabel {
        text:       missionItem.timeBetweenShots.toFixed(1) + " " + qsTr("secs")
        visible:    missionItem.editorQml.indexOf("SprayingItemEditor.qml") === -1
    }
    QGCLabel {
        text:       qsTr("Trigger Distance")
        visible:    missionItem.editorQml.indexOf("SprayingItemEditor.qml") === -1
    }
    QGCLabel {
        text:       missionItem.cameraCalc.adjustedFootprintFrontal.valueString + " " + missionItem.cameraCalc.adjustedFootprintFrontal.units
        visible:    missionItem.editorQml.indexOf("SprayingItemEditor.qml") === -1
    }
}
