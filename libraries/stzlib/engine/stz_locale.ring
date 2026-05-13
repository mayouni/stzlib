# Softanza Engine -- Locale FFI Bridge
#
# Loads stz_locale.dll/.so and wraps each C function.
# Used by: base/locale/stzLocale.ring

if isWindows()
    $cStzLocaleLib = currentdir() + "/zig-out/bin/stz_locale.dll"
but isLinux()
    $cStzLocaleLib = currentdir() + "/zig-out/lib/libstz_locale.so"
but isMacOS()
    $cStzLocaleLib = currentdir() + "/zig-out/lib/libstz_locale.dylib"
ok

if fexists($cStzLocaleLib)
    $pStzLocaleHandle = LoadLib($cStzLocaleLib)
else
    ? "WARNING: stz_locale not found at: " + $cStzLocaleLib
    $pStzLocaleHandle = NULL
ok

func EngineLocaleAMText()
    if $pStzLocaleHandle = NULL return "AM" ok
    cBuf = space(4)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_am_text", "i", "pi",
                     cBuf, 4)
    return left(cBuf, nLen)

func EngineLocalePMText()
    if $pStzLocaleHandle = NULL return "PM" ok
    cBuf = space(4)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_pm_text", "i", "pi",
                     cBuf, 4)
    return left(cBuf, nLen)

func EngineLocaleToUpper(cStr)
    if $pStzLocaleHandle = NULL return upper(cStr) ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_to_upper", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)

func EngineLocaleToLower(cStr)
    if $pStzLocaleHandle = NULL return lower(cStr) ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_to_lower", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)

func EngineLocaleToTitlecase(cStr)
    if $pStzLocaleHandle = NULL return cStr ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_to_titlecase", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)

func EngineLocaleFormatNumber(nValue, nDecimals)
    if $pStzLocaleHandle = NULL return "" + nValue ok
    cBuf = space(32)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_format_number", "i", "dipi",
                     nValue, nDecimals, cBuf, 32)
    return left(cBuf, nLen)

func EngineLocaleMonthName(nMonth)
    if $pStzLocaleHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_month_name", "i", "ipi",
                     nMonth, cBuf, 16)
    return left(cBuf, nLen)

func EngineLocaleMonthAbbr(nMonth)
    if $pStzLocaleHandle = NULL return "" ok
    cBuf = space(8)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_month_abbr", "i", "ipi",
                     nMonth, cBuf, 8)
    return left(cBuf, nLen)

func EngineLocaleDayName(nDow)
    if $pStzLocaleHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_day_name", "i", "ipi",
                     nDow, cBuf, 16)
    return left(cBuf, nLen)

func EngineLocaleDayAbbr(nDow)
    if $pStzLocaleHandle = NULL return "" ok
    cBuf = space(8)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_day_abbr", "i", "ipi",
                     nDow, cBuf, 8)
    return left(cBuf, nLen)
