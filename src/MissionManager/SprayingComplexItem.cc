/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "SprayingComplexItem.h"

const QString SprayingComplexItem::name(SprayingComplexItem::tr("Spraying"));
const char* SprayingComplexItem::jsonComplexItemTypeValue =   "spraying";

SprayingComplexItem::SprayingComplexItem(PlanMasterController* masterController, bool flyView, const QString& kmlOrShpFile)
    : SurveyComplexItem(masterController, flyView, kmlOrShpFile)
{
    _editorQml = "qrc:/qml/SprayingItemEditor.qml";

    // For Spraying, default turnaround distance to 0 regardless of multirotor overrides in base class.
    // This only affects newly created items; loads from plan/presets will overwrite this value.
    if (turnAroundDistance()) {
        turnAroundDistance()->setRawValue(0);
    }

    // For Spraying, set default spacing (AdjustedFootprintSide) to 4 m when still at default.
    if (cameraCalc() && cameraCalc()->adjustedFootprintSide()) {
        const double current = cameraCalc()->adjustedFootprintSide()->rawValue().toDouble();
        const double def     = cameraCalc()->adjustedFootprintSide()->rawDefaultValue().toDouble();
        if (current == def) {
            cameraCalc()->adjustedFootprintSide()->setRawValue(4.0);
        }
    }

    // For Spraying, set default altitude (DistanceToSurface) to 5 m when still at default.
    if (cameraCalc() && cameraCalc()->distanceToSurface()) {
        const double currentAlt = cameraCalc()->distanceToSurface()->rawValue().toDouble();
        const double defAlt     = cameraCalc()->distanceToSurface()->rawDefaultValue().toDouble();
        if (currentAlt == defAlt) {
            cameraCalc()->distanceToSurface()->setRawValue(5.0);
        }
    }
}

// Note: save/load are final in SurveyComplexItem. SprayingComplexItem intentionally
// relies on SurveyComplexItem serialization for now.


