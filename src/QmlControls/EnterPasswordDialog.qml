/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
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
import QGroundControl.ScreenTools
import QGroundControl.Controllers

QGCPopupDialog {
    id:         root
    title:      qsTr("Enter Password")
    buttons:    Dialog.Cancel

    signal authenticated()

    PasswordAuthManager { id: manager }

    Component.onCompleted: {
        // Check if password is set, if not, show message to set one first
        if (manager.authenticate("")) {
            // No password set, show message
            errorLabel.visible = true
            errorLabel.text = qsTr("No password set. Please set a password in General Settings first.")
            errorLabel.color = qgcPal.warningText
        }
    }

    function submitPassword() {
        if (passwordField.text.length === 0) {
            errorLabel.visible = true
            errorLabel.text = qsTr("Password cannot be empty.")
            return
        }
        if (!manager.authenticate(passwordField.text)) {
            errorLabel.visible = true
            errorLabel.text = qsTr("Incorrect password.")
            return
        }
        errorLabel.visible = false
        authenticated()
        close()
    }

    ColumnLayout {
        spacing: ScreenTools.defaultDialogControlSpacing

        QGCLabel {
            Layout.fillWidth:   true
            wrapMode:           Text.WordWrap
            text:               qsTr("Please enter your password to continue.")
        }

        GridLayout {
            columns:            2
            rowSpacing:         ScreenTools.defaultDialogControlSpacing
            columnSpacing:      ScreenTools.defaultDialogControlSpacing

            QGCLabel { text: qsTr("Password") }
            QGCTextField {
                id:                 passwordField
                Layout.fillWidth:   true
                echoMode:           TextInput.Password
                focus:              true
                Keys.onReleased: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.submitPassword()
                        event.accepted = true
                    }
                }
            }
        }

        QGCLabel {
            id:                 errorLabel
            Layout.fillWidth:   true
            visible:            false
            color:              qgcPal.warningText
            text:               ""
        }

        RowLayout {
            Layout.alignment:   Qt.AlignRight
            spacing:            ScreenTools.defaultFontPixelWidth

            QGCButton {
                text:       qsTr("Unlock")
                primary:    true
                enabled:    passwordField.text.length > 0
                onClicked:  root.submitPassword()
            }
        }
    }
}
