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

function calcPitchInertialVec
{
    parameter _tgtPitch.
    parameter _tgtRoll.

    local _velNormal to vCrs(ship:velocity:surface, ship:up:vector).
    local _heading to vCrs(ship:up:vector, _velNormal).

    local _fore to (angleAxis(_tgtPitch, _velNormal) * _heading).
    local _rot to angleAxis(-_tgtRoll, _fore).

    return _rot * _fore:direction.
}

function get_draw_local
{
    parameter v, c.
    return vecDraw(v(0,0,0), v, c, "", 25.0, true, 0.01).
}


// global dbgDraw1 to get_draw_local(v(0,0,0), rgb(1,0,0)).
// global dbgDraw2 to get_draw_local(v(0,0,0), rgb(1,0,1)).


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