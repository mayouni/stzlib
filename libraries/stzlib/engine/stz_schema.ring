# Softanza Engine -- Schema Definitions
#
# Loads stz_schema.dll for schema definitions.
#
# Function prefix: StzEngineSchema*

if isWindows()
    $cStzSchemaLib = $cEngineDir + "/zig-out/bin/stz_schema.dll"
but isLinux()
    $cStzSchemaLib = $cEngineDir + "/zig-out/lib/libstz_schema.so"
but isMacOS()
    $cStzSchemaLib = $cEngineDir + "/zig-out/lib/libstz_schema.dylib"
ok
if fexists($cStzSchemaLib)
    $pStzSchemaHandle = LoadLib($cStzSchemaLib)
else
    ? "WARNING: stz_schema not found at: " + $cStzSchemaLib
    $pStzSchemaHandle = NULL
ok
