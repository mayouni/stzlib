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
# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("adverb")
    $pStzAdverbHandle = NULL
but fexists($cStzAdverbLib)
    $pStzAdverbHandle = LoadLib($cStzAdverbLib)
else
    ? "WARNING: stz_adverb not found at: " + $cStzAdverbLib
    $pStzAdverbHandle = NULL
ok
