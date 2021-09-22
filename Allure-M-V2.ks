parameter targetAzimuth.

CLEARSCREEN.

runOncePath("Assend-ctl.ks").
runOncePath("Staging.ks").

print "Allure M launch sequence.".

print "   Trottle: 1.0".
LOCK THROTTLE TO 1.0.
print "   Turn rate time: 0.05".
SET SteeringManager:MAXSTOPPINGTIME TO 0.15.
SET steeringManager:rolltorquefactor to 3.

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
UNTIL SHIP:AIRSPEED > 30 { update({ return heading(targetAzimuth, 90, 0). }). }

state_cycle("Pitch 83, Roll 90").
lock steering to heading(targetAzimuth, 83, -90).
UNTIL SHIP:ALTITUDE > 2200 { update({ return heading(targetAzimuth, 83, -90). }). }

state_cycle("Pitch 81, Roll 90").
lock steering to heading(targetAzimuth, 81, -90).
UNTIL SHIP:ALTITUDE > 5600 { update({ return heading(targetAzimuth, 81, -90). }). }

state_cycle("Pitch 73, Inertial correction").
lock steering to calcPitchFrom(73, -90, ship:velocity:surface).
UNTIL SHIP:ALTITUDE > 15000  { update({ return calcPitchInertialVec(73). }). }

state_cycle("Pitch 60").
lock steering to calcPitchFrom(60, -90, ship:velocity:surface).
until any_flameout() { update({ return calcPitchInertialVec(60). }). }

state_cycle("Stg. Pitch 55").
STAGE.
set timeout to time:seconds + 2.
until time:seconds > timeout { update({ return calcPitchInertialVec(60). }). }

lock steering to calcPitchFrom(55, -90, ship:velocity:surface).
UNTIL SHIP:apoapsis > 52000  { update({ return calcPitchInertialVec(55). }). }

state_cycle("Pitch 20, Turn rate time: 0.25").
SET SteeringManager:MAXSTOPPINGTIME TO 0.25.
SET steeringManager:rolltorquefactor to 1.
lock steering to calcPitchFrom(20, 0, ship:velocity:orbit).
UNTIL any_flameout() { update({ return calcPitchInertialVec(20). }). }

state_cycle("Stg.").
STAGE.

when ship:altitude > 53000 and ship:angularvel:mag < 0.01 then {
    print "Opening payload".
    open_payload().
}

UNTIL SHIP:apoapsis > 67000  { update({ return calcPitchInertialVec(20). }). }

state_cycle("Pitch 4").
lock steering to calcPitchFrom(4, 0, ship:velocity:orbit).
UNTIL SHIP:apoapsis > 74700  { update({ return calcPitchInertialVec(4). }). }

state_cycle("Pitch -5").
lock steering to calcPitchFrom(-5, 0, ship:velocity:orbit).
UNTIL any_flameout() { update({ return calcPitchInertialVec(-5). }). }

state_cycle("Stg.").
STAGE.
UNTIL SHIP:obt:eta:APOAPSIS < 40  { update({ return calcPitchInertialVec(-5). }). }

state_cycle("Pitch 0").
lock steering to calcPitchFrom(0, 0, ship:velocity:orbit).
UNTIL SHIP:periapsis > 72000 { update({ return calcPitchInertialVec(0). }). }

unlock steering.
unlock throttle.