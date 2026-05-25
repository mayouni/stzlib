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
if fexists($cStzRelationsLib)
    $pStzRelationsHandle = LoadLib($cStzRelationsLib)
else
    ? "WARNING: stz_relations not found at: " + $cStzRelationsLib
    $pStzRelationsHandle = NULL
ok
