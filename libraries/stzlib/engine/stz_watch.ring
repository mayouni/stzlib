# Softanza Engine -- Stopwatch Operations
#
# Loads stz_watch.dll for nanosecond-precision stopwatch timing.
#
# Function prefix: StzEngineWatch*

if isWindows()
    $cStzWatchLib = $cEngineDir + "/zig-out/bin/stz_watch.dll"
but isLinux()
    $cStzWatchLib = $cEngineDir + "/zig-out/lib/libstz_watch.so"
but isMacOS()
    $cStzWatchLib = $cEngineDir + "/zig-out/lib/libstz_watch.dylib"
ok

if fexists($cStzWatchLib)
    $pStzWatchHandle = LoadLib($cStzWatchLib)
else
    ? "WARNING: stz_watch not found at: " + $cStzWatchLib
    $pStzWatchHandle = NULL
ok
