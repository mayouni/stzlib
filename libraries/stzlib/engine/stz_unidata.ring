# Softanza Engine -- Unicode Data Ring Bridge
#
# Loads stz_unidata.dll (SQLite-backed Unicode character database).
# Opens the pre-built unicode.db shipped with the engine.
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

$cStzUnidataDbPath = $cEngineDir + "/data/unicode.db"
$pStzUnidataDb = NULL

func StzEngineUnidataInit()
    if $pStzUnidataDb != NULL return ok
    if $pStzUnidataHandle = NULL return ok
    if not fexists($cStzUnidataDbPath)
        ? "WARNING: unicode.db not found at: " + $cStzUnidataDbPath
        return
    ok
    $pStzUnidataDb = StzEngineUnidataOpen($cStzUnidataDbPath)

func StzEngineUnidataShutdown()
    if $pStzUnidataDb != NULL
        StzEngineUnidataClose($pStzUnidataDb)
        $pStzUnidataDb = NULL
    ok
