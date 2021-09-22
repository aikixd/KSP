parameter targetAzimuth.

CLEARSCREEN.

runOncePath("utils/Assend-ctl").
runOncePath("utils/Staging").

print "Spark S launch sequence.".

print "   Trottle: 0.73".
LOCK THROTTLE TO 0.73.
print "   Turn rate time: 0.15".
SET SteeringManager:MAXSTOPPINGTIME TO 0.07.
SET steeringManager:rolltorquefactor to 3.

when ship:altitude > 53000 and ship:angularvel:mag < 0.01 then {
    print "Opening payload".
    open_payload().
}

print " ".
PRINT "Counting down:".
FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. 
}

markT0().
print "Launch!".
stage. 

lock steering to heading(targetAzimuth, 90, 0).
wait until ship:airspeed > 30.

state_cycle("Pitch 84").
lock steering to heading(targetAzimuth, 84, -90).
wait until ship:altitude > 1800.

state_cycle("Pitch 79").

lock steering to heading(targetAzimuth, 79, -90).
wait until ship:altitude > 5100.

state_cycle("Pitch 71, March 0.94").
lock throttle to 0.94.
lock steering to heading(targetAzimuth, 71, -90).
wait until ship:altitude > 9000.

state_cycle("Pitch 63").
lock steering to calcPitchFrom(63, -90, ship:velocity:surface). 
wait until ship:altitude > 16000.

state_cycle("Pitch 55").
lock steering to calcPitchFrom(55, -90, ship:velocity:surface). 
wait until any_flameout().

state_cycle("Stg. Match 1.0").
STAGE.
lock throttle to 1.0.
wait 2.

state_cycle("Pitch 50").
lock steering to calcPitchFrom(50, -90, ship:velocity:surface). 
wait until ship:apoapsis > 52000 and ship:altitude > 31000.

state_cycle("Pitch 19").
lock steering to calcPitchFrom(19, -90, ship:velocity:orbit). 
wait until ship:apoapsis > 68000.

state_cycle("Pitch 0, March 0.7").
lock throttle to 0.7.
lock steering to calcPitchFrom(0, -90, ship:velocity:orbit). 
wait until ship:apoapsis > 75000 or eta:apoapsis < 16 or ship:velocity:orbit:mag > 1980.

state_cycle("Pitch -4, March 0.7").
lock throttle to 0.7.
lock steering to calcPitchFrom(-4, -90, ship:velocity:orbit). 
wait until ship:apoapsis > 78000 or eta:apoapsis < 16 or ship:periapsis > 72000.


if periapsis < 70100
{
    state_cycle("March 0.0").
    lock throttle to 0.0.

    wait until eta:apoapsis < 30.

    state_cycle("March 1.0").
    lock throttle to 1.0.
    wait until periapsis > 71000 or eta:apoapsis < 2.

    if periapsis < 71000
    {
        state_cycle("Pitch 0").
        lock steering to calcPitchFrom(0, -90, ship:velocity:orbit). 
        wait until ship:periapsis > 71000.
    }
}
