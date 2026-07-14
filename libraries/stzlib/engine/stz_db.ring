# Softanza Engine -- SQLite database (R7 delivery-plane data floor)
#
# Loads stz_db.dll: open/exec/query/close over vendored sqlite3.
#
# Function prefix: StzEngineDb*

if isWindows()
    $cStzDbLib = $cEngineDir + "/zig-out/bin/stz_db.dll"
but isLinux()
    $cStzDbLib = $cEngineDir + "/zig-out/lib/libstz_db.so"
but isMacOS()
    $cStzDbLib = $cEngineDir + "/zig-out/lib/libstz_db.dylib"
ok

if fexists($cStzDbLib)
    $pStzDbHandle = LoadLib($cStzDbLib)
else
    ? "WARNING: stz_db not found at: " + $cStzDbLib
    $pStzDbHandle = NULL
ok
