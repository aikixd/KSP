// Same as orbital prograde vector for ves
function orbitTangent {
    parameter ves is ship.

    return ves:velocity:orbit:normalized.
}

// In the direction of orbital angular momentum of ves
// Typically same as Normal
function orbitBinormal {
    parameter ves is ship.

    return vcrs((ves:position - ves:body:position):normalized, orbitTangent(ves)):normalized.
}

// Perpendicular to both tangent and binormal
// Typically same as Radial In
function orbitNormal {
    parameter ves is ship.

    return vcrs(orbitBinormal(ves), orbitTangent(ves)):normalized.
}

function deorbit
{
    set steeringManager:maxstoppingtime to 5.
    
    lock steering to -ship:velocity:obt.

    wait until (ship:facing:vector:normalized + ship:velocity:obt:normalized):mag < 0.1 .
    set steeringManager:maxstoppingtime to 0.5.
    
    lock throttle to 0.2.

    wait until ship:periapsis < 0.
}

function orbitalPeriod
{
    parameter _orbit.
    
    return 2 * constant:pi * (sqrt((_orbit:semimajoraxis ^ 3) / _orbit:body:mu)).
}

function meanOrbitalSpeed
{
    parameter _semiMAjorAxis.
    parameter _mu.

    return sqrt(_mu / _semiMAjorAxis).
}


