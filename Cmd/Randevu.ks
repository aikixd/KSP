runOncePath("utils/obt-nav").

function execute
{
    local _myPeriod to orbitalPeriod(ship:orbit).
    local _targetPeriod to OrbitalPeriod(target:orbit).

    print "my inc " + ship:orbit:inclination.
    print "tgt inc " + target:orbit:inclination.
    print "rel inc " + (ship:orbit:inclination - target:orbit:inclination).
}

if (hasTarget = false)
    print "No target set. Terminating.".

else if (target:typename <> "Vessel")
    print "Target should be a vessel. Terminating".

else if (ship:orbit:eccentricity > 0.012)
    print "Vessel's eccentricity is too high. Only circular orbits are supported. Terminating.".

else if (target:orbit:eccentricity > 0.012)
    print "Target's eccentricity is too high. Only circular orbits are supported. Terminating.".

else if (ship:orbit:body <> target:orbit:body)
    print "Target is orbiting a different body. Terminating".

else execute().