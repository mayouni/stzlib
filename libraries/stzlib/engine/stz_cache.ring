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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("cache")
    $pStzCacheHandle = NULL
but fexists($cStzCacheLib)
    $pStzCacheHandle = LoadLib($cStzCacheLib)
else
    ? "WARNING: stz_cache not found at: " + $cStzCacheLib
    $pStzCacheHandle = NULL
ok
