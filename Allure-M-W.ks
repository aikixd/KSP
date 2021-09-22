CLEARSCREEN.

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

print "Allure M-W launch sequence".

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
print "cycle 1: Pitch 85".
LOCK STEERING TO HEADING(90, 85, -90).

UNTIL SHIP:ALTITUDE > 3200  { print_state(). }
print "cycle 2: Pitch 79".
LOCK STEERING TO HEADING(90, 79, -90).

UNTIL SHIP:ALTITUDE > 5600  { print_state(). }
print "cycle 2: Pitch 73".
LOCK STEERING TO HEADING(90, 73, -90).

UNTIL SHIP:ALTITUDE > 15000  { print_state(). }
print "cycle 3: Pitch 60".
LOCK STEERING TO HEADING(90, 60, -90).

UNTIL ship:STAGEDELTAV(ship:stagenum):current < 1  { print_state(). }
print "cycle 4: Stg. Pitch 55".
STAGE.
wait 2.
LOCK STEERING TO HEADING(90, 55, -90).

UNTIL SHIP:apoapsis > 52000  { print_state(). }
print "cycle 5: Pitch 20".
SET SteeringManager:MAXSTOPPINGTIME TO 0.25.
LOCK STEERING TO HEADING(90, 20, -90).

UNTIL ship:STAGEDELTAV(ship:stagenum):current < 1  { print_state(). }
print "cycle 6: Stg.".
STAGE.

when ship:altitude > 53000 and ship:angularvel:mag < 0.01 then {
    print "Open fairing".
    open_payload().
}

UNTIL SHIP:apoapsis > 67000  { print_state(). }
print "cycle 7: Pitch 4".
LOCK STEERING TO HEADING(90, 4, -90).

when ship:STAGEDELTAV(ship:stagenum):current < 1 then { 
    print "cycle 9: Stg.".
    STAGE.
}

UNTIL SHIP:apoapsis > 74700  { print_state(). }
print "cycle 8: Pitch -4".
LOCK STEERING TO HEADING(90, -5, -90).

UNTIL SHIP:obt:eta:APOAPSIS < 35  { print_state(). }
print "cycle 10: Pitch 0".
LOCK STEERING TO HEADING(90, 0, -90).

WAIT UNTIL SHIP:periapsis > 72000.

UNLOCK STEERING.
UNLOCK THROTTLE.