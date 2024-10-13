#define UNIT_EC

#include "Translates.ech"
#include "Items.ech"

unit "unit"
{

////    Declarations    ////

state Initialize;
state Nothing;

#define STOPCURRENTACTION
function int StopCurrentAction(int nCommand);

#include "Common.ech"
#include "Accuracy.ech"
#include "Camouflage.ech"
#include "Entrenchment.ech"
#include "Lights.ech"
#include "Move.ech"
#include "Special.ech"
#include "Attack.ech"
#include "Crew.ech"
#include "Events.ech"

////    Functions    ////

function int StopCurrentAction(int nCommand)
{
    UpdateLandAirMode();
    ResetCamouflageMode();
    StopCurrentActionAttacking();
	return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

////    States    ////

state Initialize
{
    return Nothing;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Nothing
{
    if (HaveCannonAndCanAttackInCurrentState())
    {
        if (!FindNothingTarget())
        {
            return Nothing;
        }
        //else state ustawiony w NothingAttack
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

////    Commands    ////

command Initialize()
{
    if (GetUnitRef())
    {
        SetCannonsAutoFire();
        SetAccuracyMode(0);//na wypadek przeladowania skryptu
        SetCamouflageMode(0);
        if (HaveCannon())
        {
            SetTimer(20);//uzywany tylko do CheckArmedState
        }
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Uninitialize()
{
    if (GetUnitRef())
    {
        ResetEnterBuilding();
        ResetAttackTarget();
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|
}
