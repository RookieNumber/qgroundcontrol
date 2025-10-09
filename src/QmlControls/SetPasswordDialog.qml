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
    title:      qsTr("Set Password")
    // Keep only Cancel in the title bar; provide our own primary action button below
    buttons:    Dialog.Cancel

    signal passwordSet()

    PasswordAuthManager { id: manager }

    function submitPassword() {
        if (newPassword.text.length === 0) {
            errorLabel.visible = true
            errorLabel.text = qsTr("Password cannot be empty.")
            return
        }
        if (newPassword.text !== confirmPassword.text) {
            errorLabel.visible = true
            errorLabel.text = qsTr("Passwords do not match.")
            return
        }
        if (!manager.setPassword(newPassword.text)) {
            errorLabel.visible = true
            errorLabel.text = qsTr("Failed to set password.")
            return
        }
        errorLabel.visible = false
        passwordSet()
        close()
    }

    ColumnLayout {
        spacing: ScreenTools.defaultDialogControlSpacing

        QGCLabel {
            Layout.fillWidth:   true
            wrapMode:           Text.WordWrap
            text:               qsTr("Enter a new password and confirm.")
        }

        GridLayout {
            id:                 grid
            columns:            2
            rowSpacing:         ScreenTools.defaultDialogControlSpacing
            columnSpacing:      ScreenTools.defaultDialogControlSpacing

            QGCLabel { text: qsTr("New Password") }
            QGCTextField {
                id:             newPassword
                Layout.fillWidth: true
                echoMode:       TextInput.Password
                focus:          true
            }

            QGCLabel { text: qsTr("Confirm Password") }
            QGCTextField {
                id:             confirmPassword
                Layout.fillWidth: true
                echoMode:       TextInput.Password
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
                text:       qsTr("Set Password")
                primary:    true
                enabled:    newPassword.text.length > 0 && newPassword.text === confirmPassword.text
                onClicked:  root.submitPassword()
            }
        }
    }
}
