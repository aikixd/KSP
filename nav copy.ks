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
    parameter _normalVec.
    parameter _orthoNormalVec.

    local hemisphere to vDot(_curVec, _tgtVec).

    print "=========".
    print "             ".
    
    local magnitudeRaw to (vdot(_tgtVec, _normalVec)).
    local orthoMagnitudeRaw to vDot(_tgtVec, _orthoNormalVec).
    
    if (hemisphere > 0) { 
        print "fore hemisphere".
        print "mag: " + arcSin(magnitudeRaw).
        return arcSin(magnitudeRaw).
    }

    // print " magnitude raw " + MagnitudeRaw.
    // print "ortho magnitude raw " + orthoMagnitudeRaw.

    
    // print "hemisphere" + hemisphere.

    // print "hemisphere deg" + arcsin(hemisphere).

    set magnitude to arcSin(magnitudeRaw).

    //print "magnitude " + magnitude.

    local hemisphereDistanceDeg to arcSin(abs(hemisphere)).
    local inverseVecDistanceDeg to 90 - hemisphereDistanceDeg.

    // print "hdd " +hemisphereDistanceDeg.
    // print "ivdd " + inverseVecDistanceDeg.

    local aftHemisphereInverse to hemisphereDistanceDeg / inverseVecDistanceDeg.
    local foreHemisphereRel to 90 / inverseVecDistanceDeg.

    

    // print "ahi " + aftHemisphereInverse.
    // print "fhr " + foreHemisphereRel.
    
    local correction to (abs(foreHemisphereRel)).

 //   print "hemi to targtet " + correction.

    //set magnitudeSimplified to magnitude * ((hemisphereDistanceDeg + 90) / (90 - hemisphereDistanceDeg)).
    set magnitudeSimplified to magnitude * ((hemisphereDistanceDeg + 90) / (90 - hemisphereDistanceDeg)).
    
    set magnitude to magnitude * aftHemisphereInverse + magnitude * correction.


  //  print "final M  :" + magnitude.
 //   print "final SM :" + magnitudeSimplified.
    

    // local orthoMagnitude to vdot(_tgtVec, _orthoNormalVec).

    // print "aft hemisphere".
    // print "mag: " + magnitude.

    // local sign to scalarSign(magnitude).
    // set magnitude to abs(magnitude).

    // local addition to 1  . //arcCos(abs(vDot(_tgtVec, _orthoNormalVec))).

    // print "vdot other: " + abs(vDot(_tgtVec, _orthoNormalVec)).
    // print "addtion: " + addition.

    
    // //set magnitude to addition + magnitude.
    
    // print "fx.mag: " + magnitude.

    // print "---".
    // print "arcCos mag: " + arcCos(magnitude).
    // print "arcCos add: " + arcCos(addition).
    // print "sign: " + arcCos(addition).


    return magnitude.// * sign). //+ arcSin(addition)) * sign.


    //local sign to scalarSign(vDot(_tgtVec, _normalVec)).
    
    //return magnitude.// * -sign.
}

function calc_both
{
    parameter _tgtVec.
    parameter _curVec.
    parameter _starVec.
    parameter _upVec.

    local hemisphere to vDot(_curVec, _tgtVec).

    print "=========".
    print "             ".
    
    local xMagnitudeRaw to vDot(_tgtVec, _starVec).
    local yMagnitudeRaw to vDot(_tgtVec, _upVec).
    
    if (hemisphere > 0) { 

        local xMagnitude to arcSin(xMagnitudeRaw).
        local yMagnitude to arcSin(yMagnitudeRaw).

        local distanceDeg to arcCos(abs(hemisphere)).

        local correction to (distanceDeg / 90).

        print "fore hemisphere".
        print "mag: " + arcSin(xMagnitudeRaw) + " " + arcSin(yMagnitudeRaw).
        return lexicon("x", arcSin(xMagnitudeRaw * correction), "y", arcSin(yMagnitudeRaw * correction)).
    }

    local xMagnitude to arcSin(xMagnitudeRaw).
    local yMagnitude to arcSin(yMagnitudeRaw).

    local hemisphereDistanceDeg to arcSin(abs(hemisphere)).
    
    local correction to (hemisphereDistanceDeg + 90) / (90 - hemisphereDistanceDeg).

    local xMagnitudeSimplified to xMagnitude * correction.
    local yMagnitudeSimplified to yMagnitude * correction.

    // print "xm " + xMagnitude.
    // print "ym " + yMagnitude.
    
    //set magnitude to magnitude * aftHemisphereInverse + magnitude * correction.

    return lexicon("x", xMagnitudeSimplified, "y", yMagnitudeSimplified).


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

set prevpitch to 0.

function test
{
    clearScreen.
    
    local localStarVec to ship:facing:starvector. //vcrs(ship:facing:vector, ship:up:vector):normalized.
    local localUpVec to ship:facing:upvector. //vCrs(localStarVec, ship:facing:vector):normalized.
    local curHdgVec to vCrs(ship:up:vector, localStarVec).


    //local hdgErr to calc_hdg_error(tgtHdgVec, curHdgVec, localStarVec).
    local hdgErr to calc_error(tgtPtcVec, ship:facing:vector, localStarVec, localUpVec).
    local ptcErr to calc_error(tgtPtcVec, ship:facing:vector, localUpVec, localStarVec).
    local ptc to calc_pitch().

    local r to calc_both(tgtPtcVec, ship:facing:vector, localStarVec, localUpVec).

    

    //print "deltaRot: " + rotateFromTo(ship:facing:vector, tgtPtcVec).
    set hdgErr to r:x.
    set ptcErr to r:y.
    
    print "  ".
    print "  ".
    print "xerrdiff " + (hdgErr - r:x).
    print "yerrdiff " + (ptcErr - r:y).
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
