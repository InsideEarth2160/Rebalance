#define PLANE_EC
#include "Translates.ech"
#include "Items.ech"

plane "plane"
{

////    Declarations    ////

state Initialize;
state Nothing;
state FlyingToAirportSlot;

int m_nAirportX, m_nAirportY, m_nAirportZ;

#define STOPCURRENTACTION
function int StopCurrentAction(int nCommand);

#include "Common.ech"
#include "Accuracy.ech"
#include "Camouflage.ech"
#include "Lights.ech"
#include "Move.ech"
#include "Special.ech"
#include "Attack.ech"

////    Functions    ////

function int StopCurrentAction(int nCommand)
{
    UpdateLandAirMode();
    SetAllowPlaneStop(false);
    StopCurrentActionAttacking();
	return true;
}//����������������������������������������������������������������������������������������������������|

function int FlyToAirportSlot()
{
    int nX, nY, nZ;
    unit uAirport;

    if (HaveAirport())
    {
        if (IsInAirportSlotPos())
        {
            return false;
        }
        if (GetAirportSlotPos(nX, nY, nZ))
        {
            TRACE4("FlyToAirportSlot", nX, nY, nZ);
            //TRACE1("FlyToAirportSlot, SetAllowPlaneStop(true)");
            SetAllowPlaneStop(true);
            CallHelicopterFlyToPoint(nX, nY, nZ);
            uAirport = GetAirport();
            m_nAirportX = uAirport.GetLocationX();
            m_nAirportY = uAirport.GetLocationY();
            m_nAirportZ = uAirport.GetLocationZ();
            return true;
        }
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

////    States    ////

state Initialize
{
    return Nothing;
}//����������������������������������������������������������������������������������������������������|

state Nothing
{
    int bBackToAirdrome;

    if (HaveCannonAndCanAttackInCurrentState())
    {
        bBackToAirdrome = PlaneMustReturnToAerodrome();
        if (!bBackToAirdrome && BackToPlaneAreaPatrol())
        {
            return state;
        }
        if (bBackToAirdrome || !FindNothingTarget())
        {
            if (HaveAirport() && !IsInAirportSlotPos())
            {
                if (FlyToAirportSlot())
                {
                    TRACE1("Nothing->FlyingToAirportSlot");
                    return FlyingToAirportSlot;
                }
            }
            return Nothing;
        }
        //else state ustawiony w NothingAttack
    }
}//����������������������������������������������������������������������������������������������������|

state FlyingToAirportSlot
{
    unit uAirport;

    if (!HaveAirport())
    {
        SetAllowPlaneStop(false);
        CallMoveToPoint(GetLocationX(), GetLocationY() + eOneGridSize);
        EndCommand(true);
        return Nothing;
    }
    if (IsMoving() || IsStartingMoving())
    {
        uAirport = GetAirport();
        if ((uAirport.GetLocationX() != m_nAirportX) ||
            (uAirport.GetLocationY() != m_nAirportY) ||
            (uAirport.GetLocationZ() != m_nAirportZ))
        {
            //zmiana wysokosci po rozwaleniu budynku ponizej
            m_nAirportX = uAirport.GetLocationX();
            m_nAirportY = uAirport.GetLocationY();
            m_nAirportZ = uAirport.GetLocationZ();
            FlyToAirportSlot();
        }
        return FlyingToAirportSlot, 10;
    }
    else
    {
        TRACE1("FlyingToAirportSlot->Nothing");
        //TRACE1("plane FlyingToAirportSlot, SetAllowPlaneStop(false)");
        SetAllowPlaneStop(false);
        EndCommand(true);
        return Nothing;
    }
}//����������������������������������������������������������������������������������������������������|

////    Events    ////

event OnHit(unit uByUnit)
{
    //nic nie robi
}//����������������������������������������������������������������������������������������������������|

event Timer()
{
    CheckArmedState();
    if (state == Moving)
    {
        //zostal ruszony z kodu (odsuniecie itp)
        //musimy zmienic stan na nothing inaczej zawsze bedzie mial moving
        state Nothing;
    }
}//����������������������������������������������������������������������������������������������������|

////    Commands    ////

command SetAirport(unit uAirport) hidden
{
    int bHaveAirport;
    int bNeedFlyToAirport;

    TRACE3("SetAirport command", GetAirport(), uAirport);

    CHECK_STOP_CURR_ACTION(eCommandSetAirport);
    bHaveAirport = HaveAirport();
    if (bHaveAirport)
    {
        TRACE1("SetAirport command, HaveAirport");
        if (GetAirport() == uAirport)
        {
            TRACE1("SetAirport command, Same Airport, do nothing");
        }
        bNeedFlyToAirport = false;
    }
    else
    {
        TRACE2("SetAirport command, call SetPlaneAirport", uAirport);
        bNeedFlyToAirport = SetPlaneAirport(uAirport);
    }
    if (bNeedFlyToAirport && FlyToAirportSlot())
    {
        // airport was explicitly set, do not return on patrol after reaching an airport
        StopPatrol(true);
        state FlyingToAirportSlot;
        SetStateDelay(0);
    }
    else
    {
        state Nothing;
        EndCommand(false);
    }
    return true;
}//����������������������������������������������������������������������������������������������������|

command Stop() button "Stop attack" item ITEM_STOP priority PRIOR_STOP
{
    CHECK_STOP_CURR_ACTION(eCommandStop);
    if (OnPatrol())
    {
        return BackToPlaneAreaPatrol();
    }
    EndCommand(true);
	state Nothing;
    SetStateDelay(0);
    return true;
}

// Set an airport if the plane isn't assigned to any airport yet
command UserObject0(unit uAirport) hidden
{
    if (GetAirport())
    {
        return true;
    }

    CommandSetAirport(uAirport);
    return true;
}

command Initialize()
{
    if (GetUnitRef())
    {
        SetCannonsAutoFire();
        SetAccuracyMode(0);//na wypadek przeladowania skryptu
        SetCamouflageMode(0);
        //bez sprawdzania HaveCannon bo w timerze jeszcze dodatkowo sprawdzany state
        SetTimer(20);
    }
    return true;
}//����������������������������������������������������������������������������������������������������|

command Uninitialize()
{
    if (GetUnitRef())
    {
        ResetEnterBuilding();
        ResetAttackTarget();
    }
    return true;
}//����������������������������������������������������������������������������������������������������|
}
