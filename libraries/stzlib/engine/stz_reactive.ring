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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("reactive")
    $pStzReactiveHandle = NULL
but fexists($cStzReactiveLib)
    $pStzReactiveHandle = LoadLib($cStzReactiveLib)
else
    ? "WARNING: stz_reactive not found at: " + $cStzReactiveLib
    $pStzReactiveHandle = NULL
ok
