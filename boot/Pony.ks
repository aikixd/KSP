compile "0:/utils/staging" to "utils/staging".
compile "0:/utils/assend-ctl" to "utils/assend-ctl".
compile "0:/utils/obt-nav" to "utils/obt-nav".

if (core:tag = "standard")
{
    print "Using config: pony-s".
    copyPath("0:/pony-s", "launch").
}

else if (core:tag = "SB")
{
    print "Using config: pony-sb".
    compile "0:/pony-sb" to "launch".
}

else if (core:tag = "SB-U")
{
    print "Using config: pony-sb-u".
    compile "0:/pony-sb-u" to "launch".
}

else
{
    print "UNKNOWN LAUNCH CONFIG: " + core:tag.
}