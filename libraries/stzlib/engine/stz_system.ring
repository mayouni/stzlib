# Softanza Engine -- Base System Ring Bridge
#
# Loads stz_system.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/system/stzSystemCall.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzSystemLib = $cEngineDir + "/zig-out/bin/stz_system.dll"
but isLinux()
    $cStzSystemLib = $cEngineDir + "/zig-out/lib/libstz_system.so"
but isMacOS()
    $cStzSystemLib = $cEngineDir + "/zig-out/lib/libstz_system.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("system")
    $pStzSystemHandle = NULL
but fexists($cStzSystemLib)
    $pStzSystemHandle = LoadLib($cStzSystemLib)
else
    ? "WARNING: stz_system not found at: " + $cStzSystemLib
    $pStzSystemHandle = NULL
ok
