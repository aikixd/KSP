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
print "cycle 1: Pitch 81".
LOCK STEERING TO HEADING(90, 81).

UNTIL SHIP:ALTITUDE > 5600  { print_state(). }
print "cycle 2: Pitch 73".
LOCK STEERING TO HEADING(90, 73).

UNTIL SHIP:ALTITUDE > 15000  { print_state(). }
print "cycle 3: Pitch 60".
LOCK STEERING TO HEADING(90, 60).

UNTIL ship:STAGEDELTAV(ship:stagenum):current < 1  { print_state(). }
print "cycle 4: Stg. Pitch 55".
STAGE.
wait 2.
LOCK STEERING TO HEADING(90, 55).

UNTIL SHIP:apoapsis > 52000  { print_state(). }
print "cycle 5: Stg. Pitch 20".
SET SteeringManager:MAXSTOPPINGTIME TO 0.4.
LOCK STEERING TO HEADING(90, 20).

WAIT UNTIL SHIP:ALTITUDE > 70000.

UNLOCK STEERING.
UNLOCK THROTTLE.