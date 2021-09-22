CLEARSCREEN.

set cycle to 1.

function state_cycle
{
    parameter txt.

    print "cycle " + cycle + ": " + txt.
    print "   OBT: " + round(ship:apoapsis) + " X " + round(ship:periapsis).
    print "   ALT: " + round(ship:altitude).
    print "   VEL: " + round(ship:airspeed).

    set cycle to cycle + 1.
}

function get_stage_engines
{
    set r to list().
    list engines in es.
    
    for e in es {
        if e:stage >= stage:number {
            r:add(e).
        }
    }

    print "Stage " + stage:number + " engine list:".
    print r.

    return r.
}

set stage_engines to get_stage_engines().

on stage:number {
    print "Stage: " + stage:number.
    set stage_engines to get_stage_engines().
    return true.
}


function any_flameout
{
    for e in stage_engines {
        if e:flameout {
            return true.
        }
    }

    return false.
}

function print_state
{
    // clearScreen.

    // print "Max thrust: " + SHIP:MAXTHRUST.
    // print "Available thrust: " + SHIP:AVAILABLETHRUST.
    // print "Thrust diff: " + (SHIP:MAXTHRUSTAT(ship:altitude) - SHIP:AVAILABLETHRUST).
    // print "Stg. dV: " + ship:STAGEDELTAV(ship:stagenum):current.

    wait 1.
}

function open_payload
{
    for p in ship:partstagged("payload")
    {
        if p:hasmodule("moduleProceduralFairing")
            p:getmodule("moduleProceduralFairing"):doevent("deploy").
    }
}

print "Allure MR launch sequence".

LOCK THROTTLE TO 1.0.
LOCK STEERING TO SHIP:FACING.

SET SteeringManager:MAXSTOPPINGTIME TO 0.05.

FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. 
}

PRINT "Launch!".
STAGE. 

UNTIL SHIP:AIRSPEED > 30 { print_state(). }
state_cycle("Pitch 81").
LOCK STEERING TO HEADING(90, 81, -90).

UNTIL SHIP:ALTITUDE > 5600  { print_state(). }
state_cycle("Pitch 73").
LOCK STEERING TO HEADING(90, 73, -90).

UNTIL SHIP:ALTITUDE > 15000  { print_state(). }
state_cycle("Pitch 60").
LOCK STEERING TO HEADING(90, 60, -90).

wait until any_flameout().
state_cycle("Stg. Pitch 55").
STAGE.
wait 2.
LOCK STEERING TO HEADING(90, 55, -90).

UNTIL SHIP:apoapsis > 52000  { print_state(). }
state_cycle("Pitch 20").
SET SteeringManager:MAXSTOPPINGTIME TO 0.25.
LOCK STEERING TO HEADING(90, 20, -90).

UNTIL ship:STAGEDELTAV(ship:stagenum):current < 1  { print_state(). }
state_cycle("Stg.").
STAGE.

when ship:altitude > 53000 and ship:angularvel:mag < 0.01 then {
    print "Open fairing".
    open_payload().
}

UNTIL SHIP:apoapsis > 67000  { print_state(). }
state_cycle("Pitch -2").
LOCK STEERING TO HEADING(90, -2, -90).

wait UNTIL any_flameout().
state_cycle("Stg.").
STAGE.

// UNTIL SHIP:apoapsis > 76000  { print_state(). }
// state_cycle("Throttle 25").
// LOCK THROTTLE TO 0.25.

// UNTIL SHIP:obt:eta:APOAPSIS < 12  { print_state(). }
// state_cycle("Throttle 100").
// LOCK THROTTLE TO 1.0.

WAIT UNTIL SHIP:periapsis > 71000.

UNLOCK STEERING.
UNLOCK THROTTLE.