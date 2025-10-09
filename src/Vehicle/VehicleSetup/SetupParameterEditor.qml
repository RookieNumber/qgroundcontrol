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

import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.Controllers

Item {
    id: root
    // Password gate
    property bool _authorized: false
    PasswordAuthManager { id: _pageAuth }

    Component.onCompleted: {
        console.log("SetupParameterEditor: Component.onCompleted")
        // Always show password dialog initially - let the dialog handle authentication
        console.log("SetupParameterEditor: Showing password dialog")
        passwordDialogLoader.sourceComponent = passwordDialogComponent
    }

    // Password dialog loader
    Loader {
        id: passwordDialogLoader
        onLoaded: {
            console.log("SetupParameterEditor: Password dialog loaded")
            if (item) {
                item.open()
            }
        }
    }

    // Password dialog factory
    Component {
        id: passwordDialogComponent
        EnterPasswordDialog {
            onAuthenticated: {
                console.log("SetupParameterEditor: Password authenticated")
                root._authorized = true
                console.log("SetupParameterEditor: _authorized set to", root._authorized)
            }
        }
    }

    // Parameter Editor - only show when authorized
    Loader {
        anchors.fill: parent
        sourceComponent: root._authorized ? parameterEditorComponent : null
        
        Component {
            id: parameterEditorComponent
            ParameterEditor {
                anchors.fill: parent
            }
        }
    }
}
