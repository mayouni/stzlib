# Softanza Engine -- Resource Tracking
#
# Loads stz_resource.dll for resource tracking.
#
# Function prefix: StzEngineResource*

if isWindows()
    $cStzResourceLib = $cEngineDir + "/zig-out/bin/stz_resource.dll"
but isLinux()
    $cStzResourceLib = $cEngineDir + "/zig-out/lib/libstz_resource.so"
but isMacOS()
    $cStzResourceLib = $cEngineDir + "/zig-out/lib/libstz_resource.dylib"
ok
if fexists($cStzResourceLib)
    $pStzResourceHandle = LoadLib($cStzResourceLib)
else
    ? "WARNING: stz_resource not found at: " + $cStzResourceLib
    $pStzResourceHandle = NULL
ok
