# Softanza Engine -- Async Task Queue
#
# Loads stz_async.dll for cooperative task scheduling.
#
# Function prefix: StzEngineAsync*

if isWindows()
    $cStzAsyncLib = $cEngineDir + "/zig-out/bin/stz_async.dll"
but isLinux()
    $cStzAsyncLib = $cEngineDir + "/zig-out/lib/libstz_async.so"
but isMacOS()
    $cStzAsyncLib = $cEngineDir + "/zig-out/lib/libstz_async.dylib"
ok

if fexists($cStzAsyncLib)
    $pStzAsyncHandle = LoadLib($cStzAsyncLib)
else
    ? "WARNING: stz_async not found at: " + $cStzAsyncLib
    $pStzAsyncHandle = NULL
ok
