parameter initAz.

CLEARSCREEN.

function get_draw_local
{
    parameter v, c.
    return vecDraw(v(0,0,0), v, c, "", 25.0, true, 0.01).
}

function getPid
{
    return pidLoop(2.0, 0.0, 0.8).
}

global cycle to 1.
function state_cycle
{
    parameter txt.

    print " ".
    print "cycle " + cycle + ": " + txt.
    print "   OBT: " + round(ship:apoapsis) + " X " + round(ship:periapsis)
        + "   ALT: " + round(ship:altitude) + "   VEL: " + round(ship:airspeed).

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

global stage_engines to get_stage_engines().

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

function open_payload
{
    for p in ship:partstagged("payload")
    {
        if p:hasmodule("moduleProceduralFairing")
            p:getmodule("moduleProceduralFairing"):doevent("deploy").
    }
}

function calc_obt_normal
{
    parameter az.

    local hdg to heading(az, 0).

    return hdg:starvector.
}

function calc_hdg_error
{
    parameter obtNormal.

    return obtNormal * ship:facing:vector.
}

function calc_pitch
{
    local dp to ship:up:vector * ship:facing:vector.

    if dp >= 1.0 return 90.

    print dp.

    return arcsin(dp).
}

global targets to lexicon(
    "vector", heading(0, 90):vector,
    "pitch", 90.0,
    "turnRate", 1.0
).

global drawTarget to get_draw_local(v(0,0,0), rgb(1,0,1)).

global last to lexicon().
last:add("seconds", time:seconds).
last:add("facing", ship:facing:vector).
last:add("star", ship:facing:starvector).
last:add("up", ship:facing:upvector).
last:add("error", v(0,0,0)).
last:add("turnRateAct", v(0,0,0)).
last:add("turnRateDes", v(0,0,0)).

global yawRotPid to pidLoop(0.8, 0.02, 0.16).
global pitchRotPid to pidLoop(0.8, 0.02, 0.16).

global yawAttPid to pidLoop(0.4, 0.38, 0.02).
global pitchAttPid to pidLoop(0.4, 0.38, 0.02).
global rollAttPid to pidLoop(0.08, 0.14, 0.01).

set yawAttPid:setpoint to 0.0.
set pitchAttPid:setpoint to 0.0.
set rollAttPid:setpoint to 0.0.

function setTurnRateLimit
{
    parameter degrees.

    set targets:turnRate to degrees.

    set yawRotPid:minoutput to -degrees.
    set yawRotPid:maxoutput to degrees.

    set pitchRotPid:minoutput to -degrees.
    set pitchRotPid:maxoutput to degrees.
}

set deltaTime to 0.0.

wait 0. // Keep deltas above zero.

function calcTurnRate
{
    parameter _starVec.
    parameter _upVec.

    local t to 0.0.

    set t to vDot(last:facing, _starVec).
    local yaw to (choose 0 if t >= 1 else arcSin(t)) / deltaTime.

    set t to vDot(last:facing, _upVec).
    local pitch to (choose 0 if t >= 1 else arcSin(t)) / deltaTime.

    set t to vDot(last:star, _upVec).
    local roll to (choose 0 if t >= 1 else arcSin(t)) / deltaTime.

    //print "Ang. rot. " + round(yaw, 3) + " " + round(pitch, 3) + " " + round(roll, 3).
    
    //local dRot to (last:facingRot * ship:facing:inverse).

    // print "drot " + drot.
    
    // local rx to (choose drot:yaw if dRot:yaw < 180 else 360 - drot:yaw) / deltaTime.
    // local ry to (choose drot:pitch if drot:pitch < 180 else 360 - drot:pitch) / deltaTime.

    // print "calc diff x: " + (yaw - rx).
    // print "calc diff y: " + (pitch - ry).

    //print "rotation diff: " + round(rx, 3) + " " + round(ry, 3).

    
    //set last:facingRot to ship:facing.

    return v(yaw, pitch, roll).// lexicon("yaw", yaw, "pitch", pitch, "roll", roll).
}

function calcVecError
{
    parameter _starVec.
    parameter _upVec.

    local _tgtVec to targets:vector.
    local _curVec to ship:facing:vector.

    local correctionNormal to vCrs(_tgtVec, _curVec).
    local correctionFore to vCrs(_curVec, correctionNormal).

    local magnitude to vDot(_curVec, _tgtVec).
    
    set correctionFore:mag to choose arcSin(correctionNormal:mag) if magnitude > 0 else arcCos(correctionNormal:mag) + 90.

    local yaw to vdot(correctionFore, _starVec).
    local pitch to vdot(correctionFore, _upVec).

    return v(yaw, pitch, 0).// lexicon("yaw", xvec, "pitch", yvec).
}

function calcPitchError
{
    parameter _starVec.
    parameter _upVec.
    
    local _locRoll to vDot(ship:facing:starvector, ship:up:vector).

    local _velNormal to vCrs(ship:velocity:surface, ship:up:vector).
    local _velHdg to vCrs(ship:up:vector, _velNormal).

    set targets:vector to (angleAxis(targets:pitch, _velNormal) * _velHdg):normalized.

    return calcVecError(_starVec, _upVec).

    // local _pitch to ship:up:vector * ship:facing:vector.
    // set _pitch to choose arcSin(_pitch) if _pitch < 1.0 else 90.
    
    // local _pitchError to targets:pitch - _pitch.
    
    // return v(
    //     -_pitchError * ( _locRoll),
    //     _pitchError * (1 - _locRoll),
    //     0
    // ).
}

function update
{
    parameter errorFn.

    clearScreen.


    set deltaTime to time:seconds - last:seconds.
    set last:seconds to time:seconds.
    local localStarVec to ship:facing:starvector.
    local localUpVec to ship:facing:upvector.
    
    //local error to calcVecError(localStarVec, localUpVec).
    local error to errorFn(localStarVec, localUpVec).
    local turnRateAct to calcTurnRate(localStarVec, localUpVec).

    local turnRateDes to v(
        yawRotPid:update(time:seconds, error:x),
        pitchRotPid:update(time:seconds, error:y),
        0
    ).

    set drawTarget:vec to targets:vector.

    // Normalize: max turn rate to max attitude.
    set yawAttPid:setpoint to -turnRateDes:x / targets:turnRate.
    set pitchAttPid:setpoint to -turnRateDes:y / targets:turnRate.

    set ship:control:yaw to yawAttPid:update(time:seconds, -turnRateAct:x).
    set ship:control:pitch to pitchAttPid:update(time:seconds, -turnRateAct:y).
    set ship:control:roll to rollAttPid:update(time:seconds, turnRateAct:z).

    set last:facing to ship:facing:vector.
    set last:star to localStarVec.
    set last:up to localUpVec.

    local pid1 to pitchRotPid.
    local pid2 to pitchAttPid.

    logfile:writeln(
        (time:seconds - t0) + 
        ", " + pid1:pterm +
        ", " + pid1:iterm +
        ", " + pid1:dterm +
        ", " + pid1:error +
        ", " + pid1:output +
        ", " + pid2:pterm + 
        ", " + pid2:iterm + 
        ", " + pid2:dterm +
        ", " + pid2:error +
        ", " + pid2:output +
        ", " + error:y +
        ", " + turnRateAct:y).

    wait 0.
}

LOCK THROTTLE TO 1.0.
setTurnRateLimit(2.4).

FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. 
}

archive:delete("pid_log.csv").
set logfile to archive:create("pid_log.csv").
logfile:writeln("time,p1,i1,d1,err1,o1,p2,i2,d2,err2,o2,errAbsPitch,avPitch").


SET t0 TO TIME:SECONDS.



print "Allure MR launch sequence".
PRINT "Launch!".
STAGE. 

UNTIL SHIP:AIRSPEED > 30 { update(calcVecError@). }

state_cycle("Pitch 81, Roll 0").
set targets:vector to heading(initAz, 81):vector.
set targets:roll to 0.0.
UNTIL SHIP:ALTITUDE > 5600 { update(calcVecError@). }

state_cycle("Pitch 73, switching to pitch target").
set targets:pitch to 73.0.
targets:remove("roll").
UNTIL SHIP:ALTITUDE > 15000  { update(calcPitchError@). }

state_cycle("Pitch 60").
set targets:pitch to 60.0.
until any_flameout() { update(calcPitchError@). }

state_cycle("Stg. Pitch 55").
STAGE.
set timeout to time:seconds + 2.
until time:seconds > timeout { update(calcPitchError@). }

set targets:pitch to 55.0.
UNTIL SHIP:apoapsis > 52000  { update(calcPitchError@). }

state_cycle("Pitch 20").
setTurnRateLimit(15.0).
set targets:pitch to 20.0.
UNTIL ship:STAGEDELTAV(ship:stagenum):current < 1  { update(calcPitchError@). }

when ship:altitude > 53000 and ship:angularvel:mag < 0.01 then {
    print "Open fairing".
    open_payload().
}

state_cycle("Stg.").
STAGE.
UNTIL SHIP:apoapsis > 67000  { update(calcPitchError@). }

state_cycle("Pitch -2").
set targets:pitch to -2.0.
UNTIL any_flameout() { update(calcPitchError@). }

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