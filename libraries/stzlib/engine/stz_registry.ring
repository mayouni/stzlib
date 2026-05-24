# Softanza Engine -- Registry (Key-Value Config Store)
#
# Loads stz_registry.dll for engine configuration/metadata storage.
#
# Function prefix: StzEngineRegistry*

if isWindows()
    $cStzRegistryLib = $cEngineDir + "/zig-out/bin/stz_registry.dll"
but isLinux()
    $cStzRegistryLib = $cEngineDir + "/zig-out/lib/libstz_registry.so"
but isMacOS()
    $cStzRegistryLib = $cEngineDir + "/zig-out/lib/libstz_registry.dylib"
ok

if fexists($cStzRegistryLib)
    $pStzRegistryHandle = LoadLib($cStzRegistryLib)
else
    ? "WARNING: stz_registry not found at: " + $cStzRegistryLib
    $pStzRegistryHandle = NULL
ok
