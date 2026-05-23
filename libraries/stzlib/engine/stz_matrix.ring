# Softanza Engine -- Base Matrix Ring Bridge
#
# Loads stz_matrix.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/number/stzMatrix.ring
# Function prefix: StzEngineMatrix*

if isWindows()
    $cStzMatrixLib = $cEngineDir + "/zig-out/bin/stz_matrix.dll"
but isLinux()
    $cStzMatrixLib = $cEngineDir + "/zig-out/lib/libstz_matrix.so"
but isMacOS()
    $cStzMatrixLib = $cEngineDir + "/zig-out/lib/libstz_matrix.dylib"
ok

if fexists($cStzMatrixLib)
    $pStzMatrixHandle = LoadLib($cStzMatrixLib)
else
    ? "WARNING: stz_matrix not found at: " + $cStzMatrixLib
    $pStzMatrixHandle = NULL
ok
