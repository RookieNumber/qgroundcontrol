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
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.ScreenTools
import QGroundControl.Controllers
import QGroundControl.Palette

Item {
    id: root

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    // Password gate
    property bool _authorized: false
    PasswordAuthManager { id: _pageAuth }

    Component.onCompleted: {
        _authorized = _pageAuth.authenticate("")
        if (!_authorized) {
            enterPasswordDialogComponent.createObject(mainWindow).open()
        }
    }

    property var model
    property real _availableHeight: availableHeight
    property real _availableWidth:  availableWidth

    ColumnLayout {
        anchors.fill: parent
        visible: root._authorized
        spacing:    ScreenTools.defaultFontPixelWidth / 4

        FactPanelController {
            id:         controller
        }

        QGCTabBar {
            id: tabBar

            Repeater {
                model: root.model
                QGCTabButton {
                    text: buttonText
                }
            }
        }

        Loader {
            id:     loader
            source: model.get(tabBar.currentIndex).tuningPage

            property bool useAutoTuning:    true
            property real availableWidth:   _availableWidth
            property real availableHeight:  _availableHeight - loader.y
        }
    }

    // Unlock overlay
    Rectangle {
        anchors.fill:       parent
        color:              qgcPal.window
        opacity:            0.98
        visible:            !root._authorized
        z:                  1000

        Column {
            spacing:            ScreenTools.defaultFontPixelHeight
            anchors.centerIn:   parent
            QGCLabel {
                text: qsTr("This page is locked. Enter password to continue.")
                horizontalAlignment: Text.AlignHCenter
            }
            QGCButton {
                text: qsTr("Unlock")
                primary: true
                onClicked: enterPasswordDialogComponent.createObject(mainWindow).open()
            }
        }
    }

    // Password dialog factory
    Component {
        id: enterPasswordDialogComponent
        EnterPasswordDialog {
            onAuthenticated: root._authorized = true
        }
    }
}
