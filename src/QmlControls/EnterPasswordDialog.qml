/****************************************************************************
*
* (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
*
* QGroundControl is licensed according to the terms in the file
* COPYING.md in the root of the source code directory.
*
****************************************************************************/

import QtQuick                      2.12
import QtQuick.Controls             2.5
import QtQuick.Layouts              1.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

QGCPopupDialog {
    id:         root
    title:      qsTr("Enter Password")
    buttons:    StandardButton.Cancel

    signal authenticated()

    PasswordAuthManager { id: manager }

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


