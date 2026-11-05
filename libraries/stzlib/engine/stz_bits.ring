# Softanza Engine -- Bit Manipulation
#
# Loads stz_bits.dll for popcount, set/clear/toggle, rotate, extract, etc.
#
# Function prefix: StzEngineBits*

if isWindows()
    $cStzBitsLib = $cEngineDir + "/zig-out/bin/stz_bits.dll"
but isLinux()
    $cStzBitsLib = $cEngineDir + "/zig-out/lib/libstz_bits.so"
but isMacOS()
    $cStzBitsLib = $cEngineDir + "/zig-out/lib/libstz_bits.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("bits")
    $pStzBitsHandle = NULL
but fexists($cStzBitsLib)
    $pStzBitsHandle = LoadLib($cStzBitsLib)
else
    ? "WARNING: stz_bits not found at: " + $cStzBitsLib
    $pStzBitsHandle = NULL
ok
