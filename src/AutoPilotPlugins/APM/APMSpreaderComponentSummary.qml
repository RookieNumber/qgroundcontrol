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

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0

Item {
    anchors.fill:   parent

    FactPanelController { id: controller; }

    property Fact _spreadEnable:           controller.getParameterFact(-1, "SPREAD_ENABLE")
    property Fact _hopperCapacity:        controller.getParameterFact(-1, "SPREAD_HOPPER_CAPACITY", false)
    property Fact _spreadRate:            controller.getParameterFact(-1, "SPREAD_RATE", false)
    property Fact _spreadMonitor:         controller.getParameterFact(-1, "SPREAD_MONITOR", false)
    property Fact _hopperLow:              controller.getParameterFact(-1, "SPREAD_HOPPER_LOW", false)
    property Fact _hopperCritical:        controller.getParameterFact(-1, "SPREAD_HOPPER_CRITICAL", false)

    property bool _spreadEnabled:         _spreadEnable.rawValue !== 0
    property bool _spreadMonitorEnabled:  _spreadMonitor.rawValue !== 0

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("Spreader System:")
            valueText: _spreadEnable.enumStringValue
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
