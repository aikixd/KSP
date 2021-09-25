global targets to lexicon(
    "fore", heading(0, 90):vector,
    "pitch", 90.0
).

global last to lexicon().
last:add("seconds", time:seconds).
last:add("facing", ship:facing:vector).
last:add("star", ship:facing:starvector).
last:add("up", ship:facing:upvector).

set deltaTime to 0.0.
set t0 to 0.0.
function markT0 { set t0 to time:seconds. }

wait 0. // Keep deltas above zero.

//***** Update functions *****//

function lerpVec
{
    parameter _vecFrom, _vecTo, factor.

    return (_vecTo - _vecFrom) * factor.
}

function getPitch
{
    local _normal to vCrs(ship:up:vector, ship:facing:vector).
    local _heading to vCrs(_normal, ship:up:vector):normalized.

    return arcCos(vDot(ship:facing:vector, _heading)).
}

function lerpScalar
{
    parameter _from, _to, _factor.

    return (_to - _from) * _factor.
}

function lerpScalarOverTime
{
    parameter 
        _fromTime, _overTime,
        _fromValue, _toValue.
    
    local _factor to (time:seconds - _fromTime) / _overTime.

    if (_factor > 1.0) set _factor to 1.0.

    local _deltaValue to _toValue - _fromValue.

    return _fromValue + (_deltaValue * _factor).
}

function calcRollError
{
    local _vecY  to vcrs(ship:up:vector,        ship:facing:forevector).
    local _trigX to vdot(ship:facing:topvector, ship:up:vector).
    local _trigY to vdot(ship:facing:topvector, _vecY).
    
    local _locRoll to arctan2(_trigY,_trigX).

    return targets:roll - _locRoll.
}

function calcTgtVec
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


function calcPitchFrom
{
    parameter _tgtPitch.
    parameter _tgtRoll.
    parameter _fromVec.

    local _velNormal to vCrs(_fromVec, ship:up:vector).
    local _velHdg to vCrs(ship:up:vector, _velNormal).

    local _fore to (angleAxis(_tgtPitch, _velNormal) * _velHdg).
    local _rot to angleAxis(_tgtRoll, _fore).

    return lookDirUp(_fore, _rot * ship:up:vector).
}

function update
{
    parameter targetFn.

    set deltaTime to time:seconds - last:seconds.
    set last:seconds to time:seconds.
    local localStarVec to ship:facing:starvector.
    local localUpVec to ship:facing:upvector.
    
    //local _target to targetFn().

    //lock steering to _target.

    set last:facing to ship:facing:vector.
    set last:star to localStarVec.
    set last:up to localUpVec.

    wait 0.
}