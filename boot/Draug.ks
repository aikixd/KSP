compile "0:/utils/staging" to "utils/staging".
compile "0:/utils/assend-ctl" to "utils/assend-ctl".
compile "0:/utils/obt-nav" to "utils/obt-nav".
copyPath("0:/cmd/stageanddeorbit", "release").

if (core:tag = "A")
{
    print "Using config: A".
    copyPath("0:/draug-a", "launch").
}

else
{
    print "UNKNOWN LAUNCH CONFIG: " + core:tag.
}