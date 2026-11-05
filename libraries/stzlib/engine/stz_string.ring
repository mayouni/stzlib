# Softanza Engine -- Base String + Char Ring Bridge
#
# Loads stz_string.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/string/stzString.ring
# Function prefix: StzEngine* (distinct from Core StkEngine*)

if isWindows()
    $cStzStringLib = $cEngineDir + "/zig-out/bin/stz_string.dll"
but isLinux()
    $cStzStringLib = $cEngineDir + "/zig-out/lib/libstz_string.so"
but isMacOS()
    $cStzStringLib = $cEngineDir + "/zig-out/lib/libstz_string.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("string")
    $pStzStringHandle = NULL
but fexists($cStzStringLib)
    $pStzStringHandle = LoadLib($cStzStringLib)
else
    ? "WARNING: stz_string not found at: " + $cStzStringLib
    $pStzStringHandle = NULL
ok
