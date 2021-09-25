parameter targetAzimuth.

CLEARSCREEN.

runOncePath("utils/Assend-ctl").
runOncePath("utils/Staging").
runOncePath("utils/Obt-Nav").

function pitchOverTime
{
    parameter 
        _overTime, 
        _targetPitch.
    local _fromTime to time:seconds.
    local _fromPitch to getPitch().

    state_cycle("Pitch " + _targetPitch + " over " + _overTime + "s").
    
    return { return heading(targetAzimuth, lerpScalarOverTime(_fromTime, _overTime, _fromPitch, _targetPitch), -90). }.
}

print "Draug A launch sequence.".
print "   Trottle: 1.0".
print "   Turn rate time: 0.15".

LOCK THROTTLE TO 1.0.
//SET SteeringManager:MAXSTOPPINGTIME TO 0.1.
//SET steeringManager:rolltorquefactor to 3.

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

lock steering to heading(targetAzimuth, 90, -90).
wait UNTIL SHIP:AIRSPEED > 30.


set steeringFn to pitchOverTime(37, 73).
lock steering to steeringFn().
wait until ship:altitude > 5000.

when ship:altitude > 18000 then { lock throttle to 0.65. }

set steeringFn to pitchOverTime(48, 55).
lock steering to steeringFn().
wait until ship:altitude > 28500.

when any_flameout() then { state_cycle("Stg."). stage. }

set steeringFn to pitchOverTime(18, 18).
lock steering to steeringFn().
wait until ship:apoapsis > 64000.

set steeringFn to pitchOverTime(5, 5).
lock steering to steeringFn().
wait until ship:apoapsis > 74000.

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

    if (ship:velocity:orbit:mag < 2020)
    {
        state_cycle("Speed burn. Pitch 0. March 1.0.").
        lock throttle to 1.0.
        lock steering to calcPitchFrom(0, -90, ship:velocity:orbit).

        wait until ship:velocity:orbit:mag > 2020 or any_flameout().
    }
    
    else if (eta:apoapsis < _timeToTgtSpeed / 2)
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

lock throttle to 0.0.
wait 0.