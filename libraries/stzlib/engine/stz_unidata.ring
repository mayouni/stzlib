# Softanza Engine -- Unicode Data Ring Bridge
#
# Loads stz_unidata.dll (SQLite-backed Unicode character database).
# ringlib_init registers all StzEngineUnidata* functions natively.
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
