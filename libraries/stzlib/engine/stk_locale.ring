# Softanza Engine -- Core Locale FFI Bridge
#
# Loads stk_locale.dll -- basic case conversion only.
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

func StkEngineLocaleToUpper(cStr)
    if $pStkLocaleHandle = NULL return upper(cStr) ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pStkLocaleHandle, "stz_locale_to_upper", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)

func StkEngineLocaleToLower(cStr)
    if $pStkLocaleHandle = NULL return lower(cStr) ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pStkLocaleHandle, "stz_locale_to_lower", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)
