# Softanza Engine -- Base File Ring Bridge
#
# Loads stz_file.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/file/stzFile.ring, base/file/stzDir.ring
# Function prefix: StzEngine* (distinct from Core StkEngine*)

if isWindows()
    $cStzFileLib = $cEngineDir + "/zig-out/bin/stz_file.dll"
but isLinux()
    $cStzFileLib = $cEngineDir + "/zig-out/lib/libstz_file.so"
but isMacOS()
    $cStzFileLib = $cEngineDir + "/zig-out/lib/libstz_file.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("file")
    $pStzFileHandle = NULL
but fexists($cStzFileLib)
    $pStzFileHandle = LoadLib($cStzFileLib)
else
    ? "WARNING: stz_file not found at: " + $cStzFileLib
    $pStzFileHandle = NULL
ok
