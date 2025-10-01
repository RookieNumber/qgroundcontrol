/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controllers   1.0

SetupPage {
    id:             tuningPage
    pageComponent:  pageComponent

    // Password gate
    property bool _authorized: false
    PasswordAuthManager { id: _pageAuth }
    Component.onCompleted: {
        _authorized = _pageAuth.authenticate("")
        if (!_authorized) {
            enterPasswordDialogComponent.createObject(mainWindow).open()
        }
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    Component {
        id: pageComponent

        PX4TuningComponentCopterAll {
            height: availableHeight
            visible: tuningPage._authorized
        }
    } // Component - pageComponent

    // Unlock overlay
    Rectangle {
        anchors.fill:       parent
        color:              qgcPal.window
        opacity:            0.98
        visible:            !tuningPage._authorized
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
            onAuthenticated: tuningPage._authorized = true
        }
    }
} // SetupPage
