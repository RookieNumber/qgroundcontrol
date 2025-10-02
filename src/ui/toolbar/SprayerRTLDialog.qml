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
import QtQuick.Layouts  1.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

QGCPopupDialog {
    id: dialog
    title: qsTr("Sprayer Tank Empty")
    buttons: StandardButton.Cancel
    
    property var vehicle
    property bool confirmed: false
    
    signal confirmed()
    signal cancelled()
    
    onAccepted: {
        if (confirmed) {
            confirmed()
        } else {
            cancelled()
        }
    }
    
    onRejected: cancelled()
    
    ColumnLayout {
        id:         column
        width:      40 * ScreenTools.defaultFontPixelWidth
        spacing:    ScreenTools.defaultFontPixelHeight
        
        QGCLabel {
            Layout.fillWidth:       true
            text:                   qsTr("Sprayer tank is empty or critically low.")
            wrapMode:               Text.WordWrap
            horizontalAlignment:    Text.AlignHCenter
        }
        
        QGCLabel {
            Layout.fillWidth:       true
            text:                   qsTr("Would you like to return to launch?")
            wrapMode:               Text.WordWrap
            horizontalAlignment:    Text.AlignHCenter
        }
        
        Rectangle {
            Layout.fillWidth:       true
            color:                  qgcPal.text
            height:                 1
        }
        
        RowLayout {
            Layout.fillWidth:       true
            spacing:                ScreenTools.defaultFontPixelWidth
            
            QGCButton {
                Layout.fillWidth:   true
                text:               qsTr("Return to Launch")
                onClicked: {
                    confirmed = true
                    dialog.accept()
                }
            }
            
            QGCButton {
                Layout.fillWidth:   true
                text:               qsTr("Continue Mission")
                onClicked: {
                    confirmed = false
                    dialog.accept()
                }
            }
        }
        
        QGCLabel {
            Layout.fillWidth:       true
            text:                   qsTr("Note: You can manually trigger RTL at any time using the RTL button.")
            wrapMode:               Text.WordWrap
            font.pointSize:         ScreenTools.smallFontPointSize
            color:                  qgcPal.warningText
            horizontalAlignment:    Text.AlignHCenter
        }
    }
}
