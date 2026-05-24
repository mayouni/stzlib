# Softanza Engine -- UUID Generation
#
# Loads stz_uuid.dll for UUID v4 generation, validation, comparison.
#
# Function prefix: StzEngineUuid*

if isWindows()
    $cStzUuidLib = $cEngineDir + "/zig-out/bin/stz_uuid.dll"
but isLinux()
    $cStzUuidLib = $cEngineDir + "/zig-out/lib/libstz_uuid.so"
but isMacOS()
    $cStzUuidLib = $cEngineDir + "/zig-out/lib/libstz_uuid.dylib"
ok

if fexists($cStzUuidLib)
    $pStzUuidHandle = LoadLib($cStzUuidLib)
else
    ? "WARNING: stz_uuid not found at: " + $cStzUuidLib
    $pStzUuidHandle = NULL
ok
