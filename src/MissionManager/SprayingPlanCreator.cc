/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "SprayingPlanCreator.h"
#include "PlanMasterController.h"
#include "MissionSettingsItem.h"
#include "SprayingComplexItem.h"

SprayingPlanCreator::SprayingPlanCreator(PlanMasterController* planMasterController, QObject* parent)
    : PlanCreator(planMasterController, SprayingComplexItem::name, QStringLiteral("/qmlimages/PlanCreator/SurveyPlanCreator.png"), parent)
{

}

void SprayingPlanCreator::createPlan(const QGeoCoordinate& mapCenterCoord)
{
    _planMasterController->removeAll();
    VisualMissionItem* takeoffItem = _missionController->insertTakeoffItem(mapCenterCoord, -1);
    _missionController->insertComplexMissionItem(SprayingComplexItem::name, mapCenterCoord, -1);
    _missionController->insertLandItem(mapCenterCoord, -1);
    _missionController->setCurrentPlanViewSeqNum(takeoffItem->sequenceNumber(), true);
}


