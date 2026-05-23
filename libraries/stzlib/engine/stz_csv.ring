# Softanza Engine -- CSV Ring Bridge
#
# Loads stz_csv.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineCsv*

if isWindows()
    $cStzCsvLib = $cEngineDir + "/zig-out/bin/stz_csv.dll"
but isLinux()
    $cStzCsvLib = $cEngineDir + "/zig-out/lib/libstz_csv.so"
but isMacOS()
    $cStzCsvLib = $cEngineDir + "/zig-out/lib/libstz_csv.dylib"
ok

if fexists($cStzCsvLib)
    $pStzCsvHandle = LoadLib($cStzCsvLib)
else
    ? "WARNING: stz_csv not found at: " + $cStzCsvLib
    $pStzCsvHandle = NULL
ok
