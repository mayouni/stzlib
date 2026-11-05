# Softanza Engine -- Base HashMap Ring Bridge
#
# Loads stz_hashmap.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/list/stzHashMap.ring (future)
# Function prefix: StzEngineHashMap*

if isWindows()
    $cStzHashMapLib = $cEngineDir + "/zig-out/bin/stz_hashmap.dll"
but isLinux()
    $cStzHashMapLib = $cEngineDir + "/zig-out/lib/libstz_hashmap.so"
but isMacOS()
    $cStzHashMapLib = $cEngineDir + "/zig-out/lib/libstz_hashmap.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("hashmap")
    $pStzHashMapHandle = NULL
but fexists($cStzHashMapLib)
    $pStzHashMapHandle = LoadLib($cStzHashMapLib)
else
    ? "WARNING: stz_hashmap not found at: " + $cStzHashMapLib
    $pStzHashMapHandle = NULL
ok
