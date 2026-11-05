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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("uuid")
    $pStzUuidHandle = NULL
but fexists($cStzUuidLib)
    $pStzUuidHandle = LoadLib($cStzUuidLib)
else
    ? "WARNING: stz_uuid not found at: " + $cStzUuidLib
    $pStzUuidHandle = NULL
ok
