# Softanza Engine -- Core Locale Ring Bridge
#
# Loads stk_locale.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: core/locale/stkLocale.ring
# Function prefix: StkEngine* (distinct from Base StzEngine*)

if isWindows()
    $cStkLocaleLib = $cEngineDir + "/zig-out/bin/stk_locale.dll"
but isLinux()
    $cStkLocaleLib = $cEngineDir + "/zig-out/lib/libstk_locale.so"
but isMacOS()
    $cStkLocaleLib = $cEngineDir + "/zig-out/lib/libstk_locale.dylib"
ok

if fexists($cStkLocaleLib)
    $pStkLocaleHandle = LoadLib($cStkLocaleLib)
else
    ? "WARNING: stk_locale not found at: " + $cStkLocaleLib
    $pStkLocaleHandle = NULL
ok
