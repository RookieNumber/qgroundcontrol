import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Vehicle 1.0

// Example QML component showing how to use the FROGS_SPRAY message data
Rectangle {
    width: 400
    height: 300
    color: "#333333"
    radius: 5

    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Title
        QGCLabel {
            text: "FROGS Spray System"
            font.pixelSize: ScreenTools.largeFontPixelSize
            font.bold: true
            color: "white"
            Layout.alignment: Qt.AlignHCenter
        }

        // Timestamp
        RowLayout {
            Layout.fillWidth: true
            QGCLabel {
                text: "Timestamp:"
                color: "lightgray"
                Layout.preferredWidth: 150
            }
            QGCLabel {
                text: activeVehicle ? activeVehicle.frogsSpray.timestamp.valueString : "N/A"
                color: "white"
                font.bold: true
            }
        }

        // Water Volume
        RowLayout {
            Layout.fillWidth: true
            QGCLabel {
                text: "Water Volume:"
                color: "lightgray"
                Layout.preferredWidth: 150
            }
            QGCLabel {
                text: activeVehicle ? activeVehicle.frogsSpray.volWater.valueString + " " + activeVehicle.frogsSpray.volWater.units : "N/A"
                color: "cyan"
                font.bold: true
            }
        }

        // Flow Rate
        RowLayout {
            Layout.fillWidth: true
            QGCLabel {
                text: "Flow Rate:"
                color: "lightgray"
                Layout.preferredWidth: 150
            }
            QGCLabel {
                text: activeVehicle ? activeVehicle.frogsSpray.flowRate.valueString + " " + activeVehicle.frogsSpray.flowRate.units : "N/A"
                color: "lime"
                font.bold: true
            }
        }

        // Actuator Control
        RowLayout {
            Layout.fillWidth: true
            QGCLabel {
                text: "Actuator Control:"
                color: "lightgray"
                Layout.preferredWidth: 150
            }
            QGCLabel {
                text: activeVehicle ? activeVehicle.frogsSpray.cActuator.valueString : "N/A"
                color: "yellow"
                font.bold: true
            }
        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }

        // Connection Status
        QGCLabel {
            text: activeVehicle ? "Vehicle Connected" : "No Vehicle Connected"
            color: activeVehicle ? "lime" : "red"
            font.italic: true
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // Example: React to changes in flow rate
    Connections {
        target: activeVehicle ? activeVehicle.frogsSpray.flowRate : null
        
        function onValueChanged() {
            if (activeVehicle) {
                var rate = activeVehicle.frogsSpray.flowRate.value
                console.log("Flow rate changed:", rate)
                
                // You can add logic here, e.g., warnings if flow rate is too high/low
                if (rate > 10.0) {
                    console.warn("WARNING: Flow rate exceeds 10 L/min!")
                }
            }
        }
    }
}

