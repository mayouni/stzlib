# Softanza Engine -- Base DateTime Ring Bridge
#
# Loads stz_datetime.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/datetime/stzDate.ring, stzTime.ring, stzDateTime.ring
# Function prefix: StzEngine* (distinct from Core StkEngine*)

if isWindows()
    $cStzDateTimeLib = $cEngineDir + "/zig-out/bin/stz_datetime.dll"
but isLinux()
    $cStzDateTimeLib = $cEngineDir + "/zig-out/lib/libstz_datetime.so"
but isMacOS()
    $cStzDateTimeLib = $cEngineDir + "/zig-out/lib/libstz_datetime.dylib"
ok

if fexists($cStzDateTimeLib)
    $pStzDateTimeHandle = LoadLib($cStzDateTimeLib)
else
    ? "WARNING: stz_datetime not found at: " + $cStzDateTimeLib
    $pStzDateTimeHandle = NULL
ok
