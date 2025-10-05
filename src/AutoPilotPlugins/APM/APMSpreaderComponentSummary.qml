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

import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls
import QGroundControl.Palette

Item {
    anchors.fill:   parent

    FactPanelController { id: controller; }

    property Fact _spreadEnable:           controller.getParameterFact(-1, "SPRAY_ENABLE", false /* reportMissing */)
    property Fact _hopperCapacity:        controller.getParameterFact(-1, "SPREAD_HOPPER_CAPACITY", false /* reportMissing */)
    property Fact _spreadRate:            controller.getParameterFact(-1, "SPREAD_RATE", false /* reportMissing */)
    property Fact _spreadMonitor:         controller.getParameterFact(-1, "SPREAD_MONITOR", false /* reportMissing */)
    property Fact _hopperLow:             controller.getParameterFact(-1, "SPREAD_HOPPER_LOW", false /* reportMissing */)
    property Fact _hopperCritical:        controller.getParameterFact(-1, "SPREAD_HOPPER_CRITICAL", false /* reportMissing */)

    property bool _spreadEnableAvailable: controller.parameterExists(-1, "SPRAY_ENABLE")
    property bool _spreadEnabled:         _spreadEnableAvailable && _spreadEnable.rawValue !== 0
    property bool _spreadMonitorEnabled:  _spreadMonitor ? _spreadMonitor.rawValue !== 0 : false

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("Spreader System:")
            valueText: _spreadEnableAvailable ? (_spreadEnabled ? qsTr("Enabled") : qsTr("Disabled")) : qsTr("Not Available")
        }

        VehicleSummaryRow {
            labelText: qsTr("Hopper Capacity:")
            valueText: _spreadEnabled && _hopperCapacity ? _hopperCapacity.valueString + " " + _hopperCapacity.units : ""
            visible:    _spreadEnabled && _hopperCapacity
        }

        VehicleSummaryRow {
            labelText: qsTr("Spread Rate:")
            valueText: _spreadEnabled && _spreadRate ? _spreadRate.valueString + " " + _spreadRate.units : ""
            visible:    _spreadEnabled && _spreadRate
        }

        VehicleSummaryRow {
            labelText: qsTr("Spread Monitor:")
            valueText: _spreadEnabled && _spreadMonitor ? _spreadMonitor.enumStringValue : ""
            visible:    _spreadEnabled && _spreadMonitor
        }

        VehicleSummaryRow {
            labelText: qsTr("Low Hopper Warning:")
            valueText: _spreadEnabled && _hopperLow ? _hopperLow.valueString + " " + _hopperLow.units : ""
            visible:    _spreadEnabled && _hopperLow
        }

        VehicleSummaryRow {
            labelText: qsTr("Critical Hopper Level:")
            valueText: _spreadEnabled && _hopperCritical ? _hopperCritical.valueString + " " + _hopperCritical.units : ""
            visible:    _spreadEnabled && _hopperCritical
        }
    }
}
