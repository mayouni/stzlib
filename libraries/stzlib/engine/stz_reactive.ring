# Softanza Engine -- Reactive Streams
#
# Loads stz_reactive.dll for observable channels and event dispatch.
#
# Function prefix: StzEngineReactive*

if isWindows()
    $cStzReactiveLib = $cEngineDir + "/zig-out/bin/stz_reactive.dll"
but isLinux()
    $cStzReactiveLib = $cEngineDir + "/zig-out/lib/libstz_reactive.so"
but isMacOS()
    $cStzReactiveLib = $cEngineDir + "/zig-out/lib/libstz_reactive.dylib"
ok

if fexists($cStzReactiveLib)
    $pStzReactiveHandle = LoadLib($cStzReactiveLib)
else
    ? "WARNING: stz_reactive not found at: " + $cStzReactiveLib
    $pStzReactiveHandle = NULL
ok
