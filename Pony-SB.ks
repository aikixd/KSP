parameter targetAzimuth.

CLEARSCREEN.

runOncePath("utils/Assend-ctl").
runOncePath("utils/Staging").
runOncePath("utils/Obt-Nav").

print "Pony SB launch sequence.".

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
wait UNTIL SHIP:AIRSPEED > 30.

state_cycle("Pitch 83, Roll 90").
lock steering to heading(targetAzimuth, 83, -90).
wait UNTIL SHIP:ALTITUDE > 1800.

state_cycle("Pitch 79").
lock steering to heading(targetAzimuth, 79, -90).
wait UNTIL SHIP:ALTITUDE > 2900.

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
wait UNTIL any_flameout().

state_cycle("Stg.").
STAGE.
wait 2.

wait UNTIL SHIP:apoapsis > 55000.

state_cycle("Pitch 20").
lock steering to calcPitchFrom(20, -90, ship:velocity:orbit).
wait UNTIL SHIP:apoapsis > 63000.

state_cycle("Pitch 4").
lock steering to calcPitchFrom(4, -90, ship:velocity:orbit).
wait UNTIL ship:velocity:orbit:mag > 1600.

state_cycle("Setting apoapsis. Pitch -1. March 1.0.").
lock steering to calcPitchFrom(-1, -90, ship:velocity:orbit).
wait UNTIL SHIP:apoapsis > 74000.

// when periapsis > 23000 then { 
//     print "Dropping 2 stage.".

//     stage. 
// }

function finalApproach
{

    local _thrustLimit to ship:availablethrust.
    local _mass to ship:mass.
    local _spd to ship:velocity:orbit:mag.
    local _tgtSpd to meanOrbitalSpeed(body("Kerbin"):radius + 71000, body("Kerbin"):mu).
    local _accLim to _thrustLimit / _mass.
    local _timeToTgtSpeed to (_tgtSpd - _spd) / _accLim.

    print "Approach params:".
    print "TRST.LIM: " + round(_thrustLimit, 3) + " MASS: " + round(_mass, 2) + " ACC.LIM: " + round(_accLim, 3).
    print "SPD: " + round(_spd, 3) + "TGT.SPD: " + round(_tgtSpd, 3) + " TGT.SPD.∆TIME: " + _timeToTgtSpeed.

    if (eta:apoapsis < _timeToTgtSpeed / 2)
    {
        state_cycle("Final burn. Pitch 0. March 1.0.").
        lock throttle to 1.0.
        lock steering to calcPitchFrom(0, -90, ship:velocity:orbit).

        wait until periapsis > 72000 or any_flameout().
    }

    else if (eta:apoapsis > 40 and eta:apoapsis < 80)
    {
        local _tgtThrottle to ((_tgtSpd - _spd) / eta:apoapsis) / _accLim.

        if (_tgtThrottle > 1.0) set _tgtThrottle to 1.0.

        state_cycle("Long approach. Pitch -4. March " + round(_tgtThrottle, 2)).
        lock throttle to _tgtThrottle.
        lock steering to calcPitchFrom(-4, 90, ship:velocity:orbit).

        wait until eta:apoapsis > 80 or eta:apoapsis < _timeToTgtSpeed / 2 or any_flameout().
    }

    else
    {
        state_cycle("Hold. Pitch 0. March 0.0").
        lock throttle to 0.0.
        lock steering to calcPitchFrom(0.0, 90, ship:velocity:orbit).

        wait until eta:apoapsis < _timeToTgtSpeed / 2 or any_flameout().
    }

    if any_flameout()
    {
        print "Dropping 2 stage.".

        lock throttle to 0.0.
        wait 0.
        stage.
        wait 2.
    }
}

until false
{
    if (periapsis > 72000)
        break.

    finalApproach().
}
