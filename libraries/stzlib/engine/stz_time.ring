# Softanza Engine -- engine-side time primitives.
# Owns the clock so every host language sees identical semantics.
#
# StzEngineTimeNowMs()        -> monotonic ns/1e6
# StzEngineTimeNowUs()        -> monotonic ns/1e3
# StzEngineTimeNowNs()        -> monotonic ns (Float64; exact to ~104d)
# StzEngineTimeWallMs()       -> wall-clock UTC ms since epoch
# StzEngineTimeSleepMs(ms)    -> blocking sleep
# StzEngineTimeResolutionNs() -> claimed resolution

if isWindows()
    $cStzTimeLib = $cEngineDir + "/zig-out/bin/stz_time.dll"
but isLinux()
    $cStzTimeLib = $cEngineDir + "/zig-out/lib/libstz_time.so"
but isMacOS()
    $cStzTimeLib = $cEngineDir + "/zig-out/lib/libstz_time.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("time")
    $pStzTimeHandle = NULL
but fexists($cStzTimeLib)
    $pStzTimeHandle = LoadLib($cStzTimeLib)
else
    ? "WARNING: stz_time not found at: " + $cStzTimeLib
    $pStzTimeHandle = NULL
ok
