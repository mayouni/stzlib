# Softanza Engine -- Base Locale Ring Bridge
#
# Loads stz_locale.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/locale/stzLocale.ring
# Function prefix: StzEngine* (distinct from Core StkEngine*)

if isWindows()
    $cStzLocaleLib = $cEngineDir + "/zig-out/bin/stz_locale.dll"
but isLinux()
    $cStzLocaleLib = $cEngineDir + "/zig-out/lib/libstz_locale.so"
but isMacOS()
    $cStzLocaleLib = $cEngineDir + "/zig-out/lib/libstz_locale.dylib"
ok

if fexists($cStzLocaleLib)
    $pStzLocaleHandle = LoadLib($cStzLocaleLib)
else
    ? "WARNING: stz_locale not found at: " + $cStzLocaleLib
    $pStzLocaleHandle = NULL
ok
