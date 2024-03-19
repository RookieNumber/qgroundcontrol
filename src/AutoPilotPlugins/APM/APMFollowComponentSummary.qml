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

    property Fact _batt1Monitor:            controller.getParameterFact(-1, "BATT_MONITOR")
    property Fact _batt2Monitor:            controller.getParameterFact(-1, "BATT2_MONITOR", false /* reportMissing */)
    property bool _batt2MonitorAvailable:   controller.parameterExists(-1, "BATT2_MONITOR")
    property bool _batt1MonitorEnabled:     _batt1Monitor.rawValue !== 0
    property bool _batt2MonitorEnabled:     _batt2MonitorAvailable && _batt2Monitor.rawValue !== 0
    property Fact _battCapacity:            controller.getParameterFact(-1, "BATT_CAPACITY", false /* reportMissing */)
    property Fact _batt2Capacity:           controller.getParameterFact(-1, "BATT2_CAPACITY", false /* reportMissing */)
    property bool _battCapacityAvailable:   controller.parameterExists(-1, "BATT_CAPACITY")

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("Baterai Monitor:")
            valueText: _batt1Monitor.enumStringValue
        }

        VehicleSummaryRow {
            labelText: qsTr("Baterai Kapasitas:")
            valueText:  _batt1MonitorEnabled ? _battCapacity.valueString + " " + _battCapacity.units : ""
            visible:    _batt1MonitorEnabled
        }

        VehicleSummaryRow {
            labelText:  qsTr("Sprayer Monitor:")
            valueText:  qsTr("Kapasitas Tangki")
            visible:    _batt2MonitorAvailable
        }


        VehicleSummaryRow {
            labelText:  qsTr("Kapasitas Tangki:")
            valueText:  _batt2MonitorEnabled ? _batt2Capacity.valueString + " " + "mL" : ""
            visible:    _batt2MonitorEnabled
        }
    }
}
