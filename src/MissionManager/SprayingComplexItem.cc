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
}

// Note: save/load are final in SurveyComplexItem. SprayingComplexItem intentionally
// relies on SurveyComplexItem serialization for now.


