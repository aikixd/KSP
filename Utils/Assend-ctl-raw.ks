global targets to lexicon(
    "vector", heading(0, 90):vector,
    "pitch", 90.0,
    "turnRate", 1.0
).

global last to lexicon().
last:add("seconds", time:seconds).
last:add("facing", ship:facing:vector).
last:add("star", ship:facing:starvector).
last:add("up", ship:facing:upvector).
last:add("error", v(0,0,0)).
last:add("turnRateAct", v(0,0,0)).
last:add("turnRateDes", v(0,0,0)).

set deltaTime to 0.0.
set t0 to 0.0.
function markT0 { set t0 to time:seconds. }

global yawRotPid to pidLoop(0.8, 0.08, 0.16).
global pitchRotPid to pidLoop(0.8, 0.08, 0.16).
global rollRotPid to pidLoop(0.8, 0.08, 0.16).

global yawAttPid to pidLoop(0.6, 0.38, 0.02, -1, 1).
global pitchAttPid to pidLoop(0.6, 0.38, 0.02, -1, 1).
global rollAttPid to pidLoop(0.2, 0.02, 0.005, -1, 1).

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

    set rollRotPid:minoutput to -degrees * 4.
    set rollRotPid:maxoutput to degrees * 4.
}

wait 0. // Keep deltas above zero.

//***** Update functions *****//

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

    return v(yaw, pitch, roll).
}

function calcRollError
{
    local _vecY  to vcrs(ship:up:vector,        ship:facing:forevector).
    local _trigX to vdot(ship:facing:topvector, ship:up:vector).
    local _trigY to vdot(ship:facing:topvector, _vecY).
    
    local _locRoll to arctan2(_trigY,_trigX).

    return targets:roll - _locRoll.
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

    return v(
        yaw, 
        pitch, 
        choose calcRollError() if targets:haskey("roll") else 0).
}

function calcPitchError
{
    parameter _starVec.
    parameter _upVec.
    
    local _velNormal to vCrs(ship:velocity:surface, ship:up:vector).
    local _velHdg to vCrs(ship:up:vector, _velNormal).

    set targets:vector to (angleAxis(targets:pitch, _velNormal) * _velHdg):normalized.

    return calcVecError(_starVec, _upVec).
}

function update
{
    parameter errorFn.

    set deltaTime to time:seconds - last:seconds.
    set last:seconds to time:seconds.
    local localStarVec to ship:facing:starvector.
    local localUpVec to ship:facing:upvector.
    
    local error to errorFn(localStarVec, localUpVec).
    local turnRateAct to calcTurnRate(localStarVec, localUpVec).

    local turnRateDes to v(
        yawRotPid:update(time:seconds, error:x),
        pitchRotPid:update(time:seconds, error:y),
        rollRotPid:update(time:seconds, error:z)
    ).

    // Normalize: max turn rate to max attitude.
    set yawAttPid:setpoint to -turnRateDes:x.// / targets:turnRate.
    set pitchAttPid:setpoint to -turnRateDes:y.// / targets:turnRate.
    set rollAttPid:setpoint to -turnRateDes:z.// / targets:turnRate.

    set ship:control:yaw to yawAttPid:update(time:seconds, -turnRateAct:x).
    set ship:control:pitch to pitchAttPid:update(time:seconds, -turnRateAct:y).
    set ship:control:roll to rollAttPid:update(time:seconds, turnRateAct:z).

    set last:facing to ship:facing:vector.
    set last:star to localStarVec.
    set last:up to localUpVec.

    log_file:writeln(
        (time:seconds - t0) + 

        ", " + yawRotPid:pterm +
        ", " + yawRotPid:iterm +
        ", " + yawRotPid:dterm +
        ", " + yawRotPid:error +
        ", " + yawRotPid:output +
        
        ", " + yawAttPid:pterm + 
        ", " + yawAttPid:iterm + 
        ", " + yawAttPid:dterm +
        ", " + yawAttPid:error +
        ", " + yawAttPid:output +
        
        ", " + pitchRotPid:pterm +
        ", " + pitchRotPid:iterm +
        ", " + pitchRotPid:dterm +
        ", " + pitchRotPid:error +
        ", " + pitchRotPid:output +
        
        ", " + pitchAttPid:pterm + 
        ", " + pitchAttPid:iterm + 
        ", " + pitchAttPid:dterm +
        ", " + pitchAttPid:error +
        ", " + pitchAttPid:output +

        ", " + rollRotPid:pterm +
        ", " + rollRotPid:iterm +
        ", " + rollRotPid:dterm +
        ", " + rollRotPid:error +
        ", " + rollRotPid:output +
        
        ", " + rollAttPid:pterm + 
        ", " + rollAttPid:iterm + 
        ", " + rollAttPid:dterm +
        ", " + rollAttPid:error +
        ", " + rollAttPid:output +
        
        ", " + error:x +
        ", " + turnRateAct:x +

        ", " + error:y +
        ", " + turnRateAct:y).

    wait 0.
}

archive:delete("pid_log.csv").
set log_file to archive:create("pid_log.csv").
log_file:writeln(
    "time," +
    "yawP1,yawI1,yawD1,yawErr1,yawO1," + 
    "yawP2,yawI2,yawD2,yawErr2,yawO2," +
    "pitchP1,pitchI1,pitchD1,pitchErr1,pitchO1," + 
    "pitchP2,pitchI2,pitchD2,pitchErr2,pitchO2," +
    "rollP1,rollI1,rollD1,rollErr1,rollO1," + 
    "rollP2,rollI2,rollD2,rollErr2,rollO2," +
    "yawErrAbs,yawAngVel" +
    "pitchErrAbs,pitchAngVel").