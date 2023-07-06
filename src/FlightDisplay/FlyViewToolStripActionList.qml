/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQml.Models 2.12

import QGroundControl           1.0
import QGroundControl.Controls  1.0

ToolStripActionList {
    id: _root

    signal displayPreFlightChecklist





    model: [
        ToolStripAction {
            text:           qsTr("Fly")
            iconSource:     "/qmlimages/PaperPlane.svg"
//            onTriggered:    mainWindow.showFlyView()
        },
        ToolStripAction {
            text:                   qsTr("File")
//            enabled:                !_planMasterController.syncInProgress
            visible:                true
            showAlternateIcon:      _planMasterController.dirty
            iconSource:             "/qmlimages/MapSync.svg"
            alternateIconSource:    "/qmlimages/MapSyncChanged.svg"
//            dropPanelComponent:     syncDropPanel
            onTriggered:    mainWindow.showPlanView()
        },
        PreFlightCheckListShowAction { onTriggered: displayPreFlightChecklist() },
        GuidedActionTakeoff { },
        GuidedActionLand { },
        GuidedActionRTL { },
        GuidedActionPause { },
        GuidedActionActionList { }
    ]
}
