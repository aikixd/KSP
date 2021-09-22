
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
    local r to list().
    list engines in es.
    
    print "Stage " + stage:number + " engine list:".
    
    for e in es {
        if e:stage >= stage:number {
            r:add(e).
            print "   - " + e:name.
        }
    }

    return r.
}

global stage_engines to get_stage_engines().

on stage:number {
    print " ".
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