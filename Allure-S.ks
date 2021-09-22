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

function print_state
{
    // clearScreen.

    // print "Max thrust: " + SHIP:MAXTHRUST.
    // print "Available thrust: " + SHIP:AVAILABLETHRUST.
    // print "Thrust diff: " + (SHIP:MAXTHRUSTAT(ship:altitude) - SHIP:AVAILABLETHRUST).
    // print "Stg. dV: " + ship:STAGEDELTAV(ship:stagenum):current.

    wait 1.
}

print "Allure S launch sequence".

function open_payload
{
    for p in ship:partstagged("payload")
    {
        if p:hasmodule("moduleProceduralFairing")
            p:getmodule("moduleProceduralFairing"):doevent("deploy").
    }
}

LOCK THROTTLE TO 1.0.
LOCK STEERING TO SHIP:FACING.

SET SteeringManager:MAXSTOPPINGTIME TO 0.05.

//This is our countdown loop, which cycles from 10 to 0
PRINT "Counting down:".
FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. // pauses the script here for 1 second.
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
state_cycle("Pitch 55").
LOCK STEERING TO HEADING(90, 55, -90).

UNTIL ship:STAGEDELTAV(ship:stagenum):current < 1  { print_state(). }
state_cycle("Stg. Pitch 48").
STAGE.
wait 4.
LOCK STEERING TO HEADING(90, 48, -90).

UNTIL SHIP:apoapsis > 52000  { print_state(). }
state_cycle("Pitch 15").
SET SteeringManager:MAXSTOPPINGTIME TO 0.25.
LOCK STEERING TO HEADING(90, 15, -90).

when ship:altitude > 53000 and ship:angularvel:mag < 0.01 then {
    print "Open fairing".
    open_payload().
}

UNTIL SHIP:apoapsis > 67000  { print_state(). }
state_cycle("Pitch 0").
LOCK STEERING TO HEADING(90, 0, -90).

UNTIL ship:STAGEDELTAV(ship:stagenum):current < 1  { print_state(). }
state_cycle("Stg.").
STAGE.

UNTIL SHIP:apoapsis > 74000  { print_state(). }
state_cycle("Throttle 25").
LOCK THROTTLE TO 0.25.

UNTIL SHIP:obt:eta:APOAPSIS < 12  { print_state(). }
state_cycle("Throttle 100").
LOCK THROTTLE TO 1.0.

WAIT UNTIL SHIP:periapsis > 72000.

LOCK THROTTLE TO 0.0.

UNLOCK STEERING.
UNLOCK THROTTLE.