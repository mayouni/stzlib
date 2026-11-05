# Softanza Engine -- Random Ring Bridge
#
# Loads stz_random.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineRandom*

if isWindows()
    $cStzRandomLib = $cEngineDir + "/zig-out/bin/stz_random.dll"
but isLinux()
    $cStzRandomLib = $cEngineDir + "/zig-out/lib/libstz_random.so"
but isMacOS()
    $cStzRandomLib = $cEngineDir + "/zig-out/lib/libstz_random.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("random")
    $pStzRandomHandle = NULL
but fexists($cStzRandomLib)
    $pStzRandomHandle = LoadLib($cStzRandomLib)
else
    ? "WARNING: stz_random not found at: " + $cStzRandomLib
    $pStzRandomHandle = NULL
ok
