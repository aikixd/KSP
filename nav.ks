function get_draw_local
{
    parameter v, c.
    return vecDraw(v(0,0,0), v, c, "", 3.0, true, 0.03).
}

function calc_obt_normal
{
    parameter az.

    local hdg to heading(az, 0).

    return hdg:starvector.
}

function scalarSign
{
    parameter x.
    if (x >= 0)
        return 1.
    return -1.
}

function calc_hdg_error
{
    parameter _tgtVec.
    parameter _curVec.
    parameter _normalVec.

    local magnitude to vdot(_curVec, _tgtVec) - 1.

    local sign to scalarSign(vDot(_tgtVec, _normalVec)).
    
    return magnitude * -sign.
}

function calc_error
{
    parameter _tgtVec.
    parameter _curVec.
    parameter _starVec.
    parameter _upVec.

    local correctionNormal to vCrs(_tgtVec, _curVec).
    local correctionFore to vCrs(_curVec, correctionNormal).


    local magnitude to vDot(_curVec, _tgtVec).

    
    print "tgt nrm mag " + correctionNormal:mag.
    
    set correctionFore:mag to choose arcSin(correctionNormal:mag) if magnitude > 0 else arcCos(correctionNormal:mag) + 90.

    // set tgtNormalDraw:vec to correctionNormal.
    // set tgtCorrDraw:start to ship:facing:vector * 3.
    // set tgtCorrDraw:vec to correctionFore / 90.

    local xvec to vdot(correctionFore, _starVec).
    local yvec to vdot(correctionFore, _upVec).

    return lexicon("x", xvec, "y", yvec).
}

function calc_pitch
{
    local dp to ship:up:vector * ship:facing:vector.

    if dp >= 1.0 return 90.

    //print dp.

    return arcsin(dp).
}

clearVecDraws().

set az to 22.
set pitch to 81.
set tgtHdgVec to heading(az, 0):vector.
set tgtPtcVec to heading(az, pitch):vector.

set tgtRot to heading(az, pitch).


set tgtHdgDraw to get_draw_local(tgtHdgVec, rgb(1, 1, 1)).
set curHdgDraw to get_draw_local(v(0,0,0), rgb(0, 0, 1)).
set hdgErrDraw to get_draw_local(v(0,0,0), rgb(1, 0.4, 0)).

set tgtPtcDraw to get_draw_local(tgtPtcVec, rgb(0.2, 0.7, 1)).
set curFcgDraw to get_draw_local(tgtPtcVec, rgb(0.4, 0.0, 1)).
set ptcErrDraw to get_draw_local(v(0,0,0), rgb(1, 0, 0)).

set locNormalDraw to get_draw_local(v(0,0,0), rgb(0, 1, 1)).
set locUpDraw to get_draw_local(v(0,0,0), rgb(0, 1, 0)).

set tgtNormalDraw to get_draw_local(v(0,0,0), rgb(1, 0, 1)).
set tgtCorrDraw to get_draw_local(v(0,0,0), rgb(1,1,0)).

set prevpitch to 0.

function test
{
    clearScreen.
    
    local localStarVec to ship:facing:starvector. //vcrs(ship:facing:vector, ship:up:vector):normalized.
    local localUpVec to ship:facing:upvector. //vCrs(localStarVec, ship:facing:vector):normalized.
    local curHdgVec to vCrs(ship:up:vector, localStarVec).


    
    local error to calc_error(tgtPtcVec, ship:facing:vector, localStarVec, localUpVec).
    local hdgErr to error:x.
    local ptcErr to error:y.
    

    

    //print "deltaRot: " + rotateFromTo(ship:facing:vector, tgtPtcVec).
    set hdgErr to error:x.
    set ptcErr to error:y.
    
    print "  ".
    print "  ".
    print "xerrdiff " + (hdgErr - error:x).
    print "yerrdiff " + (ptcErr - error:y).
    print "hdg: " + hdgErr.
    print "ptc: " + ptcErr.
    print "ptcDiff " + (ptcErr - prevpitch).

    set prevpitch to ptcErr.


    set curFcgDraw:vec to ship:facing:vector.
    set locNormalDraw:vec to localStarVec.
    set locUpDraw:vec to localUpVec.
    set curHdgDraw:vec to curHdgVec.
    
    set hdgErrDraw:start to ship:facing:vector * 3.
    set hdgErrDraw:vec to localStarVec * hdgErr / 90.

    set ptcErrDraw:start to ship:facing:vector * 3.
    set ptcErrDraw:vec to localUpVec * ptcErr / 90.
}

until false { test(). wait(0.05). }
