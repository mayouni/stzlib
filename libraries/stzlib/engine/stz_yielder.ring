# Softanza Engine -- Base Yielder Ring Bridge
#
# Loads stz_yielder.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/yielder/stzYielder.ring
# Function prefix: StzEngineYielder*

if isWindows()
    $cStzYielderLib = $cEngineDir + "/zig-out/bin/stz_yielder.dll"
but isLinux()
    $cStzYielderLib = $cEngineDir + "/zig-out/lib/libstz_yielder.so"
but isMacOS()
    $cStzYielderLib = $cEngineDir + "/zig-out/lib/libstz_yielder.dylib"
ok

if fexists($cStzYielderLib)
    $pStzYielderHandle = LoadLib($cStzYielderLib)
else
    ? "WARNING: stz_yielder not found at: " + $cStzYielderLib
    $pStzYielderHandle = NULL
ok
