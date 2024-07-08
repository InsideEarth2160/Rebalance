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
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

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
        if (MustBackToAirportForRefuel() || IsOutOfAmmo() || !FindNothingTarget())
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
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

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
        TRACE1("FlyingToAirportSlot");
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
        SetAllowPlaneStop(false);
        EndCommand(true);
        return Nothing;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

////    Events    ////

event OnHit(unit uByUnit)
{
    //nic nie robi
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event Timer()
{
    CheckArmedState();
    if (state == Moving)
    {
        //zostal ruszony z kodu (odsuniecie itp)
        //musimy zmienic stan na nothing inaczej zawsze bedzie mial moving
        state Nothing;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

////    Commands    ////

command SetAirport(unit uAirport) hidden
{
    CHECK_STOP_CURR_ACTION(eCommandSetAirport);
    if ((HaveAirport() || SetPlaneAirport(uAirport)) && FlyToAirportSlot())
    {
        state FlyingToAirportSlot;
        SetStateDelay(0);
    }
    else
    {
        state Nothing;
        EndCommand(false);
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

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
