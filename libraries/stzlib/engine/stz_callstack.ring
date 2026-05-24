# Softanza Engine -- Call Stack Tracker
#
# Loads stz_callstack.dll for explicit call chain tracking.
#
# Function prefix: StzEngineCallstack*

if isWindows()
    $cStzCallstackLib = $cEngineDir + "/zig-out/bin/stz_callstack.dll"
but isLinux()
    $cStzCallstackLib = $cEngineDir + "/zig-out/lib/libstz_callstack.so"
but isMacOS()
    $cStzCallstackLib = $cEngineDir + "/zig-out/lib/libstz_callstack.dylib"
ok

if fexists($cStzCallstackLib)
    $pStzCallstackHandle = LoadLib($cStzCallstackLib)
else
    ? "WARNING: stz_callstack not found at: " + $cStzCallstackLib
    $pStzCallstackHandle = NULL
ok
