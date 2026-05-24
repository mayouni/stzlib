# Softanza Engine -- Logging Operations
#
# Loads stz_log.dll for leveled logging with message buffer.
#
# Function prefix: StzEngineLog*

if isWindows()
    $cStzLogLib = $cEngineDir + "/zig-out/bin/stz_log.dll"
but isLinux()
    $cStzLogLib = $cEngineDir + "/zig-out/lib/libstz_log.so"
but isMacOS()
    $cStzLogLib = $cEngineDir + "/zig-out/lib/libstz_log.dylib"
ok

if fexists($cStzLogLib)
    $pStzLogHandle = LoadLib($cStzLogLib)
else
    ? "WARNING: stz_log not found at: " + $cStzLogLib
    $pStzLogHandle = NULL
ok
