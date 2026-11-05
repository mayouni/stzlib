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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("db")
    $pStzDbHandle = NULL
but fexists($cStzDbLib)
    $pStzDbHandle = LoadLib($cStzDbLib)
else
    ? "WARNING: stz_db not found at: " + $cStzDbLib
    $pStzDbHandle = NULL
ok
