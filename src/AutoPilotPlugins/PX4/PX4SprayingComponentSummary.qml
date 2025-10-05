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
import QGroundControl.Palette

Item {
    anchors.fill:   parent

    FactPanelController { id: controller; }

    property Fact _sprayEnable:             controller.getParameterFact(-1, "SPRAY_ENABLE", false /* reportMissing */)
    property Fact _tankCapacity:            controller.getParameterFact(-1, "SPRAY_TANK_CAP", false /* reportMissing */)
    property Fact _flowRate:                controller.getParameterFact(-1, "SPRAY_FLOW_RATE", false /* reportMissing */)
    property bool _sprayEnableAvailable:    controller.parameterExists(-1, "SPRAY_ENABLE")
    property bool _sprayEnabled:            _sprayEnableAvailable && _sprayEnable.rawValue !== 0

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("Spraying System")
            valueText: _sprayEnableAvailable ? (_sprayEnabled ? qsTr("Enabled") : qsTr("Disabled")) : qsTr("Not Available")
        }

        VehicleSummaryRow {
            labelText: qsTr("Tank Capacity")
            valueText:  _sprayEnabled && _tankCapacity ? _tankCapacity.valueString + " " + _tankCapacity.units : ""
            visible:    _sprayEnabled
        }

        VehicleSummaryRow {
            labelText:  qsTr("Flow Rate")
            valueText:  _sprayEnabled && _flowRate ? _flowRate.valueString + " " + _flowRate.units : ""
            visible:    _sprayEnabled
        }
    }
}

