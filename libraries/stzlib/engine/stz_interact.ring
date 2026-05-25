# Softanza Engine -- Interaction Engine
#
# Loads stz_interact.dll for interaction sessions.
#
# Function prefix: StzEngineInteract*

if isWindows()
    $cStzInteractLib = $cEngineDir + "/zig-out/bin/stz_interact.dll"
but isLinux()
    $cStzInteractLib = $cEngineDir + "/zig-out/lib/libstz_interact.so"
but isMacOS()
    $cStzInteractLib = $cEngineDir + "/zig-out/lib/libstz_interact.dylib"
ok
if fexists($cStzInteractLib)
    $pStzInteractHandle = LoadLib($cStzInteractLib)
else
    ? "WARNING: stz_interact not found at: " + $cStzInteractLib
    $pStzInteractHandle = NULL
ok
