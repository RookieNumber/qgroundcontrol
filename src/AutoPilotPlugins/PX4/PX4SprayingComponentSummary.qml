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

    property Fact _sprayEnable:           controller.getParameterFact(-1, "SPRAY_ENABLE", false)
    property Fact _tankCapacity:          controller.getParameterFact(-1, "SPRAY_TANK_CAPACITY", false)
    property Fact _flowRate:              controller.getParameterFact(-1, "SPRAY_FLOW_RATE", false)
    property Fact _flowMonitor:           controller.getParameterFact(-1, "SPRAY_FLOW_MONITOR", false)
    property Fact _tankLow:               controller.getParameterFact(-1, "SPRAY_TANK_LOW", false)
    property Fact _tankCritical:          controller.getParameterFact(-1, "SPRAY_TANK_CRITICAL", false)

    property bool _sprayEnabled:          _sprayEnable && _sprayEnable.rawValue !== 0
    property bool _flowMonitorEnabled:    _flowMonitor && _flowMonitor.rawValue !== 0

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("Spraying System:")
            valueText: _sprayEnable ? _sprayEnable.enumStringValue : qsTr("N/A")
        }

        VehicleSummaryRow {
            labelText: qsTr("Tank Capacity:")
            valueText: _sprayEnabled && _tankCapacity ? _tankCapacity.valueString + " " + _tankCapacity.units : ""
            visible:    _sprayEnabled && _tankCapacity
        }

        VehicleSummaryRow {
            labelText: qsTr("Flow Rate:")
            valueText: _sprayEnabled && _flowRate ? _flowRate.valueString + " " + _flowRate.units : ""
            visible:    _sprayEnabled && _flowRate
        }

        VehicleSummaryRow {
            labelText: qsTr("Flow Monitor:")
            valueText: _sprayEnabled && _flowMonitor ? _flowMonitor.enumStringValue : ""
            visible:    _sprayEnabled && _flowMonitor
        }

        VehicleSummaryRow {
            labelText: qsTr("Low Tank Warning:")
            valueText: _sprayEnabled && _tankLow ? _tankLow.valueString + " " + _tankLow.units : ""
            visible:    _sprayEnabled && _tankLow
        }

        VehicleSummaryRow {
            labelText: qsTr("Critical Tank Level:")
            valueText: _sprayEnabled && _tankCritical ? _tankCritical.valueString + " " + _tankCritical.units : ""
            visible:    _sprayEnabled && _tankCritical
        }
    }
}


