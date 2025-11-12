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

import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls

Item {
    anchors.fill: parent

    FactPanelController { id: controller }

    property Fact _missionSpeed: controller.getParameterFact(-1, "WPNAV_SPEED", false /* reportMissing */)
    property Fact _loiterSpeed: controller.getParameterFact(-1, "LOIT_SPEED", false /* reportMissing */)

    Column {
        anchors.fill: parent

        VehicleSummaryRow {
            labelText: qsTr("Mission cruise speed:")
            valueText: fact ? fact.valueString + " " + fact.units : ""
            visible:   controller.parameterExists(-1, "WPNAV_SPEED")

            property Fact fact: _missionSpeed
        }

        VehicleSummaryRow {
            labelText: qsTr("Loiter speed:")
            valueText: fact ? fact.valueString + " " + fact.units : ""
            visible:   controller.parameterExists(-1, "LOIT_SPEED")

            property Fact fact: _loiterSpeed
        }
    }
}
