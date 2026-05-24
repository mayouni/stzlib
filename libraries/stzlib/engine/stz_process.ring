# Softanza Engine -- Process Info
#
# Loads stz_process.dll for process/platform introspection.
#
# Function prefix: StzEngineProcess*

if isWindows()
    $cStzProcessLib = $cEngineDir + "/zig-out/bin/stz_process.dll"
but isLinux()
    $cStzProcessLib = $cEngineDir + "/zig-out/lib/libstz_process.so"
but isMacOS()
    $cStzProcessLib = $cEngineDir + "/zig-out/lib/libstz_process.dylib"
ok

if fexists($cStzProcessLib)
    $pStzProcessHandle = LoadLib($cStzProcessLib)
else
    ? "WARNING: stz_process not found at: " + $cStzProcessLib
    $pStzProcessHandle = NULL
ok
