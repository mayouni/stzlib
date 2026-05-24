# Softanza Engine -- Polyglot Ring Bridge
#
# Loads stz_polyglot.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEnginePolyglot*

if isWindows()
    $cStzPolyglotLib = $cEngineDir + "/zig-out/bin/stz_polyglot.dll"
but isLinux()
    $cStzPolyglotLib = $cEngineDir + "/zig-out/lib/libstz_polyglot.so"
but isMacOS()
    $cStzPolyglotLib = $cEngineDir + "/zig-out/lib/libstz_polyglot.dylib"
ok

if fexists($cStzPolyglotLib)
    $pStzPolyglotHandle = LoadLib($cStzPolyglotLib)
else
    ? "WARNING: stz_polyglot not found at: " + $cStzPolyglotLib
    $pStzPolyglotHandle = NULL
ok
