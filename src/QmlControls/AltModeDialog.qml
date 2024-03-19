/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 2.12
import QtQuick.Dialogs  1.3
import QtQuick.Layouts  1.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

QGCPopupDialog {
    title:   qsTr("Konfigurasi ketinggian")
    buttons: StandardButton.Close

    property var rgRemoveModes
    property var updateAltModeFn
    property var currentAltMode

    Component.onCompleted: {
        // Check for custom build override on AMSL usage
        if (!QGroundControl.corePlugin.options.showMissionAbsoluteAltitude && currentAltMode != QGroundControl.AltitudeModeAbsolute) {
            rgRemoveModes.push(QGroundControl.AltitudeModeAbsolute)
        }

        // Remove modes specified by consumer
        for (var i=0; i<rgRemoveModes.length; i++) {
            for (var j=0; j<buttonModel.count; j++) {
                if (buttonModel.get(j).modeValue == rgRemoveModes[i]) {
                    buttonModel.remove(j)
                    break
                }
            }
        }


        buttonRepeater.model = buttonModel
    }

    ListModel {
        id: buttonModel

        ListElement {
            modeName:   qsTr("Relatif")
            help:       qsTr("Menghitung ketinggian relatif terhadap lokasi take-off.")
            modeValue:  QGroundControl.AltitudeModeRelative
        }
        ListElement {
            modeName:   qsTr("DPL")
            help:       qsTr("Menghitung ketinggian relatif terhadap permukaan air laut.")
            modeValue:  QGroundControl.AltitudeModeAbsolute
        }
//        ListElement {
//            modeName:   qsTr("Calculated Above Terrain")
//            help:       qsTr("Specified altitudes are distance above terrain. Actual altitudes sent to vehicle are calculated from terrain data and sent as AMSL values.")
//            modeValue:  QGroundControl.AltitudeModeCalcAboveTerrain
//        }
        ListElement {
            modeName:   qsTr("Terrain")
            help:       qsTr("Menghitung ketinggian berdasarkan data permukaan tanah. Ketinggian sebenarnya dihitung langsung oleh pesawat ketika terbang dengan mengambil data ketinggian dari peta maupun dari sensor ketinggian.")
            modeValue:  QGroundControl.AltitudeModeTerrainFrame
        }
//        ListElement {
//            modeName:   qsTr("Mixed Modes")
//            help:       qsTr("The altitude mode can differ for each individual item.")
//            modeValue:  QGroundControl.AltitudeModeMixed
//        }
    }

    Column {
        spacing: ScreenTools.defaultFontPixelWidth

        Repeater {
            id: buttonRepeater

            Button {
                hoverEnabled:   true
                checked:        modeValue == currentAltMode

                background: Rectangle {
                    radius: ScreenTools.defaultFontPixelHeight / 2
                    color:  pressed | hovered | checked ? QGroundControl.globalPalette.buttonHighlight: QGroundControl.globalPalette.button
                }

                contentItem: Column {
                    spacing: 0

                    QGCLabel {
                        id:     modeNameLabel
                        text:   modeName
                        color:  pressed | hovered | checked ? QGroundControl.globalPalette.buttonHighlightText: QGroundControl.globalPalette.buttonText
                    }

                    QGCLabel {
                        width:              ScreenTools.defaultFontPixelWidth * 40
                        text:               help
                        wrapMode:           Label.WordWrap
                        font.pointSize:     ScreenTools.smallFontPointSize
                        color:              modeNameLabel.color
                    }
                }

                onClicked: {
                    updateAltModeFn(modeValue)
                    close()
                }
            }
        }
    }
}
