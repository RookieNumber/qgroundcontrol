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

    // Tank Configuration parameters
    property Fact _tankcFull:              controller.getParameterFact(-1, "TANK_C_FULL", false)
    property Fact _tankFull:               controller.getParameterFact(-1, "TANK_FULL", false)
    property Fact _tankIFlow:              controller.getParameterFact(-1, "TANK_I_FLOW", false)
    property Fact _tankPFlow:              controller.getParameterFact(-1, "TANK_P_FLOW", false)
    
    // Flow Control parameters
    property Fact _tankMaxFlow:            controller.getParameterFact(-1, "TANK_MAX_FLOW", false)
    property Fact _tankSetFlow:           controller.getParameterFact(-1, "TANK_SET_FLOW", false)
    property Fact _tankTRt:                controller.getParameterFact(-1, "TANK_T_RTL", false)

    // Parameter availability checks
    property bool _tankcFullAvailable:     controller.parameterExists(-1, "TANK_C_FULL")
    property bool _tankFullAvailable:      controller.parameterExists(-1, "TANK_FULL")
    property bool _tankSetFlowAvailable:   controller.parameterExists(-1, "TANK_SET_FLOW")
    property bool _tankMaxFlowAvailable:   controller.parameterExists(-1, "TANK_MAX_FLOW")
    property bool _tankTRtAvailable:       controller.parameterExists(-1, "TANK_T_RTL")

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("Tank Volume:")
            valueText: _tankFullAvailable && _tankFull ? _tankFull.valueString + " " + _tankFull.units : qsTr("N/A")
            visible:    _tankFullAvailable
        }

        VehicleSummaryRow {
            labelText: qsTr("Calibration Tank Volume:")
            valueText: _tankcFullAvailable && _tankcFull ? _tankcFull.valueString + " " + _tankcFull.units : ""
            visible:    _tankcFullAvailable && _tankcFull
        }

        VehicleSummaryRow {
            labelText: qsTr("Flow Rate:")
            valueText: _tankSetFlowAvailable && _tankSetFlow ? _tankSetFlow.valueString + " " + _tankSetFlow.units : ""
            visible:    _tankSetFlowAvailable && _tankSetFlow
        }

        VehicleSummaryRow {
            labelText: qsTr("Calibration Flow Rate:")
            valueText: _tankMaxFlowAvailable && _tankMaxFlow ? _tankMaxFlow.valueString + " " + _tankMaxFlow.units : ""
            visible:    _tankMaxFlowAvailable && _tankMaxFlow
        }

        VehicleSummaryRow {
            labelText: qsTr("RTL Threshold:")
            valueText: _tankTRtAvailable && _tankTRt ? _tankTRt.valueString + " " + _tankTRt.units : ""
            visible:    _tankTRtAvailable && _tankTRt
        }
    }
}
