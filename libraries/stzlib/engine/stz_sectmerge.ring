# Softanza Engine -- SectMerge Ring Bridge
#
# Loads stz_sectmerge.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineSmp*

if isWindows()
    $cStzSectmergeLib = $cEngineDir + "/zig-out/bin/stz_sectmerge.dll"
but isLinux()
    $cStzSectmergeLib = $cEngineDir + "/zig-out/lib/libstz_sectmerge.so"
but isMacOS()
    $cStzSectmergeLib = $cEngineDir + "/zig-out/lib/libstz_sectmerge.dylib"
ok

if fexists($cStzSectmergeLib)
    $pStzSectmergeHandle = LoadLib($cStzSectmergeLib)
else
    ? "WARNING: stz_sectmerge not found at: " + $cStzSectmergeLib
    $pStzSectmergeHandle = NULL
ok
