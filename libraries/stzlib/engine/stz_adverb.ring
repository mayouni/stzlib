# Softanza Engine -- Adverbs
#
# Loads stz_adverb.dll for composable operation modifiers.
#
# Function prefix: StzEngineAdverb*

if isWindows()
    $cStzAdverbLib = $cEngineDir + "/zig-out/bin/stz_adverb.dll"
but isLinux()
    $cStzAdverbLib = $cEngineDir + "/zig-out/lib/libstz_adverb.so"
but isMacOS()
    $cStzAdverbLib = $cEngineDir + "/zig-out/lib/libstz_adverb.dylib"
ok
if fexists($cStzAdverbLib)
    $pStzAdverbHandle = LoadLib($cStzAdverbLib)
else
    ? "WARNING: stz_adverb not found at: " + $cStzAdverbLib
    $pStzAdverbHandle = NULL
ok
