# Softanza Engine -- Sequence Generator
#
# Loads stz_sequence.dll for sequence generator.
#
# Function prefix: StzEngineSequence*

if isWindows()
    $cStzSequenceLib = $cEngineDir + "/zig-out/bin/stz_sequence.dll"
but isLinux()
    $cStzSequenceLib = $cEngineDir + "/zig-out/lib/libstz_sequence.so"
but isMacOS()
    $cStzSequenceLib = $cEngineDir + "/zig-out/lib/libstz_sequence.dylib"
ok
# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("sequence")
    $pStzSequenceHandle = NULL
but fexists($cStzSequenceLib)
    $pStzSequenceHandle = LoadLib($cStzSequenceLib)
else
    ? "WARNING: stz_sequence not found at: " + $cStzSequenceLib
    $pStzSequenceHandle = NULL
ok
