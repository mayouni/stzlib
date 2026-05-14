# Softanza Engine -- Base Locale FFI Bridge
#
# Loads stz_locale.dll -- full features, superset of Core.
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

# ── Case Conversion (Core: to_upper, to_lower / Base adds: to_titlecase) ──

func StzEngineLocaleToUpper(cStr)
    if $pStzLocaleHandle = NULL return upper(cStr) ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_to_upper", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)

func StzEngineLocaleToLower(cStr)
    if $pStzLocaleHandle = NULL return lower(cStr) ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_to_lower", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)

func StzEngineLocaleToTitlecase(cStr)
    if $pStzLocaleHandle = NULL return cStr ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_to_titlecase", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)

# ── AM/PM (Base only) ──

func StzEngineLocaleAMText()
    if $pStzLocaleHandle = NULL return "AM" ok
    cBuf = space(4)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_am_text", "i", "pi",
                     cBuf, 4)
    return left(cBuf, nLen)

func StzEngineLocalePMText()
    if $pStzLocaleHandle = NULL return "PM" ok
    cBuf = space(4)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_pm_text", "i", "pi",
                     cBuf, 4)
    return left(cBuf, nLen)

# ── Number Formatting (Base only) ──

func StzEngineLocaleFormatNumber(nValue, nDecimals)
    if $pStzLocaleHandle = NULL return "" + nValue ok
    cBuf = space(32)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_format_number", "i", "dipi",
                     nValue, nDecimals, cBuf, 32)
    return left(cBuf, nLen)

# ── Month/Day Names (Base only) ──

func StzEngineLocaleMonthName(nMonth)
    if $pStzLocaleHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_month_name", "i", "ipi",
                     nMonth, cBuf, 16)
    return left(cBuf, nLen)

func StzEngineLocaleMonthAbbr(nMonth)
    if $pStzLocaleHandle = NULL return "" ok
    cBuf = space(8)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_month_abbr", "i", "ipi",
                     nMonth, cBuf, 8)
    return left(cBuf, nLen)

func StzEngineLocaleDayName(nDow)
    if $pStzLocaleHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_day_name", "i", "ipi",
                     nDow, cBuf, 16)
    return left(cBuf, nLen)

func StzEngineLocaleDayAbbr(nDow)
    if $pStzLocaleHandle = NULL return "" ok
    cBuf = space(8)
    nLen = CallCFunc($pStzLocaleHandle, "stz_locale_day_abbr", "i", "ipi",
                     nDow, cBuf, 8)
    return left(cBuf, nLen)
