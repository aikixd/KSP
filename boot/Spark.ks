copyPath("0:/utils/staging", "utils/staging").
copyPath("0:/utils/assend-ctl", "utils/assend-ctl").
copyPath("0:/cmd/stageanddeorbit", "release").

if (core:tag = "standard")
{
    print "Using config: spark-s".
    copyPath("0:/spark-s", "launch").
}
else
{
    print "UNKNOWN LAUNCH CONFIG: " + core:tag.
}