# Softanza Engine -- Universal Operations
#
# Loads stz_univops.dll for type queries, byte ops, int utilities.
#
# Function prefix: StzEngineUnivOps*

if isWindows()
    $cStzUnivopsLib = $cEngineDir + "/zig-out/bin/stz_univops.dll"
but isLinux()
    $cStzUnivopsLib = $cEngineDir + "/zig-out/lib/libstz_univops.so"
but isMacOS()
    $cStzUnivopsLib = $cEngineDir + "/zig-out/lib/libstz_univops.dylib"
ok

if fexists($cStzUnivopsLib)
    $pStzUnivopsHandle = LoadLib($cStzUnivopsLib)
else
    ? "WARNING: stz_univops not found at: " + $cStzUnivopsLib
    $pStzUnivopsHandle = NULL
ok
