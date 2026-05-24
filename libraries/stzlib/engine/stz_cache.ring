# Softanza Engine -- Cache Operations
#
# Loads stz_cache.dll for string key-value caching with TTL.
#
# Function prefix: StzEngineCache*

if isWindows()
    $cStzCacheLib = $cEngineDir + "/zig-out/bin/stz_cache.dll"
but isLinux()
    $cStzCacheLib = $cEngineDir + "/zig-out/lib/libstz_cache.so"
but isMacOS()
    $cStzCacheLib = $cEngineDir + "/zig-out/lib/libstz_cache.dylib"
ok

if fexists($cStzCacheLib)
    $pStzCacheHandle = LoadLib($cStzCacheLib)
else
    ? "WARNING: stz_cache not found at: " + $cStzCacheLib
    $pStzCacheHandle = NULL
ok
