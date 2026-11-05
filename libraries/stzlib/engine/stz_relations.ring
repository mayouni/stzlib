# Softanza Engine -- Relations Engine
#
# Loads stz_relations.dll for relations engine.
#
# Function prefix: StzEngineRelations*

if isWindows()
    $cStzRelationsLib = $cEngineDir + "/zig-out/bin/stz_relations.dll"
but isLinux()
    $cStzRelationsLib = $cEngineDir + "/zig-out/lib/libstz_relations.so"
but isMacOS()
    $cStzRelationsLib = $cEngineDir + "/zig-out/lib/libstz_relations.dylib"
ok
# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("relations")
    $pStzRelationsHandle = NULL
but fexists($cStzRelationsLib)
    $pStzRelationsHandle = LoadLib($cStzRelationsLib)
else
    ? "WARNING: stz_relations not found at: " + $cStzRelationsLib
    $pStzRelationsHandle = NULL
ok
