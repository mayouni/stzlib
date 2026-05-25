# Softanza Engine -- Intent Engine
#
# Loads stz_intent.dll for intent engine.
#
# Function prefix: StzEngineIntent*

if isWindows()
    $cStzIntentLib = $cEngineDir + "/zig-out/bin/stz_intent.dll"
but isLinux()
    $cStzIntentLib = $cEngineDir + "/zig-out/lib/libstz_intent.so"
but isMacOS()
    $cStzIntentLib = $cEngineDir + "/zig-out/lib/libstz_intent.dylib"
ok
if fexists($cStzIntentLib)
    $pStzIntentHandle = LoadLib($cStzIntentLib)
else
    ? "WARNING: stz_intent not found at: " + $cStzIntentLib
    $pStzIntentHandle = NULL
ok
