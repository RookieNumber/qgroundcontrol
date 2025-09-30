/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include "SurveyComplexItem.h"

class SprayingComplexItem : public SurveyComplexItem
{
    Q_OBJECT

public:
    /// @param flyView true: Created for use in the Fly View, false: Created for use in the Plan View
    /// @param kmlOrShpFile Polygon comes from this file, empty for default polygon
    SprayingComplexItem(PlanMasterController* masterController, bool flyView, const QString& kmlOrShpFile);

    // Overrides for naming so UI shows Spraying instead of Survey
    QString patternName(void) const override { return name; }
    QString commandDescription(void) const override { return tr("Spraying"); }
    QString commandName(void) const override { return tr("Spraying"); }
    QString abbreviation(void) const override { return tr("Sp"); }
    QString presetsSettingsGroup(void) override { return QStringLiteral("Spraying"); }

    static const QString name;
    static const char*   jsonComplexItemTypeValue;
};


