parameter targetAzimuth.

CLEARSCREEN.

runOncePath("utils/Assend-ctl").
runOncePath("utils/Staging").

print "Pony S launch sequence.".

print "   Trottle: 1.0".
LOCK THROTTLE TO 1.0.
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
PRINT "Launch!".
STAGE. 

lock steering to heading(targetAzimuth, 90, 0).
wait UNTIL SHIP:AIRSPEED > 30.// { update({ return heading(targetAzimuth, 90, 0). }). }

state_cycle("Pitch 83, Roll 90").
lock steering to heading(targetAzimuth, 83, -90).
wait UNTIL SHIP:ALTITUDE > 1800.// { update({ return heading(targetAzimuth, 83, -90). }). }

state_cycle("Pitch 79").
lock steering to heading(targetAzimuth, 79, -90).
wait UNTIL SHIP:ALTITUDE > 2900.// { update({ return heading(targetAzimuth, 82, -90). }). }

state_cycle("Pitch 73").
lock steering to heading(targetAzimuth, 73, -90).
wait UNTIL SHIP:ALTITUDE > 5100.

state_cycle("Pitch 67").
lock steering to heading(targetAzimuth, 67, -90).
wait UNTIL SHIP:ALTITUDE > 10800.

state_cycle("Pitch 55").
lock steering to heading(targetAzimuth, 55, -90).
wait UNTIL any_flameout().

state_cycle("Stg.").
STAGE.
wait 2.

state_cycle("Pitch 50, Inertial correction").
lock steering to calcPitchFrom(50, -90, ship:velocity:orbit).
wait UNTIL SHIP:apoapsis > 55000.

state_cycle("Pitch 20").
lock steering to calcPitchFrom(20, -90, ship:velocity:orbit).
wait UNTIL SHIP:apoapsis > 63000.

state_cycle("Pitch 4").
lock steering to calcPitchFrom(4, -90, ship:velocity:orbit).
wait UNTIL ship:velocity:orbit:mag > 1580.

state_cycle("Pitch -2, March 0.4").
lock throttle to 0.4.
lock steering to calcPitchFrom(-2, -90, ship:velocity:orbit).
wait UNTIL any_flameout() or ship:periapsis > 22000 or ship:apoapsis > 79000.

state_cycle("Stg. Pitch 0, Hold").
lock throttle to 0.0.
wait 0.2. // Wait till engine is off.
stage.
lock steering to calcPitchFrom(0, -90, ship:velocity:orbit).
wait UNTIL ship:obt:eta:apoapsis < 13.

state_cycle("Stg. Pitch 0, March").
lock throttle to 1.0.
wait UNTIL SHIP:periapsis > 72000.