# Softanza Engine -- Unicode Data
#
# Loads stz_unidata.dll which auto-opens the pre-built unicode.db
# on DLL load. Ring functions take no handle -- the engine manages
# the database internally, like utf8proc manages its own tables.
#
# Used by: base/common/stzUnicodeData.ring
# Function prefix: StzEngineUnidata*

if isWindows()
    $cStzUnidataLib = $cEngineDir + "/zig-out/bin/stz_unidata.dll"
but isLinux()
    $cStzUnidataLib = $cEngineDir + "/zig-out/lib/libstz_unidata.so"
but isMacOS()
    $cStzUnidataLib = $cEngineDir + "/zig-out/lib/libstz_unidata.dylib"
ok

if fexists($cStzUnidataLib)
    $pStzUnidataHandle = LoadLib($cStzUnidataLib)
else
    ? "WARNING: stz_unidata not found at: " + $cStzUnidataLib
    $pStzUnidataHandle = NULL
ok
