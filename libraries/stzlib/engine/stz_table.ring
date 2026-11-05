# Softanza Engine -- Base Table Ring Bridge
#
# Loads stz_table.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/table/stzTable.ring, base/table/stzPivotTable.ring
# Function prefix: StzEngineTable*, StzEnginePivot*

if isWindows()
    $cStzTableLib = $cEngineDir + "/zig-out/bin/stz_table.dll"
but isLinux()
    $cStzTableLib = $cEngineDir + "/zig-out/lib/libstz_table.so"
but isMacOS()
    $cStzTableLib = $cEngineDir + "/zig-out/lib/libstz_table.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("table")
    $pStzTableHandle = NULL
but fexists($cStzTableLib)
    $pStzTableHandle = LoadLib($cStzTableLib)
else
    ? "WARNING: stz_table not found at: " + $cStzTableLib
    $pStzTableHandle = NULL
ok
