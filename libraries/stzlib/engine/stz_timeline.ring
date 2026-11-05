# Softanza Engine -- Timeline Ring Bridge
#
# Loads stz_timeline.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineTimeline*

if isWindows()
    $cStzTimelineLib = $cEngineDir + "/zig-out/bin/stz_timeline.dll"
but isLinux()
    $cStzTimelineLib = $cEngineDir + "/zig-out/lib/libstz_timeline.so"
but isMacOS()
    $cStzTimelineLib = $cEngineDir + "/zig-out/lib/libstz_timeline.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("timeline")
    $pStzTimelineHandle = NULL
but fexists($cStzTimelineLib)
    $pStzTimelineHandle = LoadLib($cStzTimelineLib)
else
    ? "WARNING: stz_timeline not found at: " + $cStzTimelineLib
    $pStzTimelineHandle = NULL
ok
