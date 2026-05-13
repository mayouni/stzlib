# Softanza Engine -- Ring FFI Bridge
#
# This file bridges Ring to the Softanza Engine (Zig shared library).
# It loads softanza_engine.dll/.so and wraps each C function.
#
# Usage: load "stzengine.ring" before using Engine-backed classes.
#
# NOTE: Ring's LoadLib/GetCFunc is used for dynamic loading.
# The Engine replaces Qt dependencies with pure Zig implementations.

# Detect platform and load the engine library
if isWindows()
    $cEngineLib = currentdir() + "/zig-out/bin/softanza_engine.dll"
but isLinux()
    $cEngineLib = currentdir() + "/zig-out/lib/libsoftanza_engine.so"
but isMacOS()
    $cEngineLib = currentdir() + "/zig-out/lib/libsoftanza_engine.dylib"
ok

if fexists($cEngineLib)
    $pEngineHandle = LoadLib($cEngineLib)
else
    ? "WARNING: Softanza Engine not found at: " + $cEngineLib
    ? "Run 'zig build' in the engine/ directory first."
    $pEngineHandle = NULL
ok

# ════════════════════════════════════════════
# Tier 1: String Functions
# ════════════════════════════════════════════

func EngineStringNew()
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_new", "p", "")

func EngineStringFrom(cStr)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_from", "p", "pi",
                     cStr, len(cStr))

func EngineStringFree(pHandle)
    if $pEngineHandle = NULL return ok
    CallCFunc($pEngineHandle, "stz_string_free", "v", "p", pHandle)

func EngineStringData(pHandle)
    if $pEngineHandle = NULL return "" ok
    return CallCFunc($pEngineHandle, "stz_string_data", "p", "p", pHandle)

func EngineStringSize(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_string_size", "i", "p", pHandle)

func EngineStringCount(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_string_count", "i", "p", pHandle)

func EngineStringAppend(pHandle, cStr)
    if $pEngineHandle = NULL return ok
    CallCFunc($pEngineHandle, "stz_string_append", "v", "ppi",
              pHandle, cStr, len(cStr))

func EngineStringIndexOf(pHandle, cNeedle)
    if $pEngineHandle = NULL return -1 ok
    return CallCFunc($pEngineHandle, "stz_string_index_of", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

func EngineStringContains(pHandle, cNeedle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_string_contains", "i", "ppi",
                     pHandle, cNeedle, len(cNeedle))

func EngineStringStartsWith(pHandle, cPrefix)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_string_starts_with", "i", "ppi",
                     pHandle, cPrefix, len(cPrefix))

func EngineStringEndsWith(pHandle, cSuffix)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_string_ends_with", "i", "ppi",
                     pHandle, cSuffix, len(cSuffix))

func EngineStringMid(pHandle, nStart, nLength)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_mid", "p", "pii",
                     pHandle, nStart, nLength)

func EngineStringLeft(pHandle, nLength)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_left", "p", "pi",
                     pHandle, nLength)

func EngineStringRight(pHandle, nLength)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_right", "p", "pi",
                     pHandle, nLength)

func EngineStringTrimmed(pHandle)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_trimmed", "p", "p",
                     pHandle)

func EngineStringReplace(pHandle, cOld, cNew)
    if $pEngineHandle = NULL return ok
    CallCFunc($pEngineHandle, "stz_string_replace", "v", "ppipi",
              pHandle, cOld, len(cOld), cNew, len(cNew))

func EngineStringToUpper(pHandle)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_to_upper", "p", "p",
                     pHandle)

func EngineStringToLower(pHandle)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_string_to_lower", "p", "p",
                     pHandle)

# ════════════════════════════════════════════
# Tier 1: Unicode Character Functions
# ════════════════════════════════════════════

func EngineCharUnicode(cChar)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_char_unicode", "i", "p", cChar)

func EngineCharIsLetter(nCodepoint)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_char_is_letter", "i", "i",
                     nCodepoint)

func EngineCharIsDigit(nCodepoint)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_char_is_digit", "i", "i",
                     nCodepoint)

func EngineCharIsUpper(nCodepoint)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_char_is_upper", "i", "i",
                     nCodepoint)

func EngineCharIsLower(nCodepoint)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_char_is_lower", "i", "i",
                     nCodepoint)

# ════════════════════════════════════════════
# Tier 2: Date Functions
# ════════════════════════════════════════════

func EngineDateNew(nYear, nMonth, nDay)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_date_new", "p", "iii",
                     nYear, nMonth, nDay)

func EngineDateToday()
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_date_today", "p", "")

func EngineDateFree(pHandle)
    if $pEngineHandle = NULL return ok
    CallCFunc($pEngineHandle, "stz_date_free", "v", "p", pHandle)

func EngineDateYear(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_date_year", "i", "p", pHandle)

func EngineDateMonth(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_date_month", "i", "p", pHandle)

func EngineDateDay(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_date_day", "i", "p", pHandle)

func EngineDateDayOfWeek(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_date_day_of_week", "i", "p", pHandle)

func EngineDateDayOfYear(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_date_day_of_year", "i", "p", pHandle)

func EngineDateDaysInMonth(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_date_days_in_month", "i", "p", pHandle)

func EngineDateDaysInYear(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_date_days_in_year", "i", "p", pHandle)

func EngineDateIsLeapYear(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_date_is_leap_year", "i", "p", pHandle)

func EngineDateAddDays(pHandle, nDays)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_date_add_days", "p", "pi",
                     pHandle, nDays)

func EngineDateDiffDays(pHandle1, pHandle2)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_date_diff_days", "i", "pp",
                     pHandle1, pHandle2)

func EngineDateToString(pHandle)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(32)
    nLen = CallCFunc($pEngineHandle, "stz_date_to_string", "i", "ppi",
                     pHandle, cBuf, 32)
    return left(cBuf, nLen)

func EngineDateToISO(pHandle)
    return EngineDateToString(pHandle)

func EngineDateCompare(pHandle1, pHandle2)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_date_compare", "i", "pp",
                     pHandle1, pHandle2)

func EngineDateDayName(pHandle)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pEngineHandle, "stz_date_day_name", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

func EngineDateMonthName(pHandle)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pEngineHandle, "stz_date_month_name", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

# ════════════════════════════════════════════
# Tier 2: Time Functions
# ════════════════════════════════════════════

func EngineTimeNew(nHour, nMinute, nSecond)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_time_new", "p", "iii",
                     nHour, nMinute, nSecond)

func EngineTimeNewMs(nHour, nMinute, nSecond, nMs)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_time_new_ms", "p", "iiii",
                     nHour, nMinute, nSecond, nMs)

func EngineTimeNow()
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_time_now", "p", "")

func EngineTimeFree(pHandle)
    if $pEngineHandle = NULL return ok
    CallCFunc($pEngineHandle, "stz_time_free", "v", "p", pHandle)

func EngineTimeHour(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_time_hour", "i", "p", pHandle)

func EngineTimeMinute(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_time_minute", "i", "p", pHandle)

func EngineTimeSecond(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_time_second", "i", "p", pHandle)

func EngineTimeMillisecond(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_time_millisecond", "i", "p", pHandle)

func EngineTimeHour12(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_time_hour12", "i", "p", pHandle)

func EngineTimeIsPM(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_time_is_pm", "i", "p", pHandle)

func EngineTimeAddSeconds(pHandle, nSecs)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_time_add_seconds", "p", "pi",
                     pHandle, nSecs)

func EngineTimeToString(pHandle)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pEngineHandle, "stz_time_to_string", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

func EngineTimeTo12h(pHandle)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pEngineHandle, "stz_time_to_string_12h", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

func EngineTimeCompare(pHandle1, pHandle2)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_time_compare", "i", "pp",
                     pHandle1, pHandle2)

# ════════════════════════════════════════════
# Tier 2: DateTime Functions
# ════════════════════════════════════════════

func EngineDateTimeNew(nYear, nMonth, nDay, nHour, nMinute, nSecond)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_datetime_new", "p", "iiiiii",
                     nYear, nMonth, nDay, nHour, nMinute, nSecond)

func EngineDateTimeNow()
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_datetime_now", "p", "")

func EngineDateTimeFromUnix(nTimestamp)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_datetime_from_unix", "p", "i",
                     nTimestamp)

func EngineDateTimeFree(pHandle)
    if $pEngineHandle = NULL return ok
    CallCFunc($pEngineHandle, "stz_datetime_free", "v", "p", pHandle)

func EngineDateTimeYear(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_datetime_year", "i", "p", pHandle)

func EngineDateTimeMonth(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_datetime_month", "i", "p", pHandle)

func EngineDateTimeDay(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_datetime_day", "i", "p", pHandle)

func EngineDateTimeHour(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_datetime_hour", "i", "p", pHandle)

func EngineDateTimeMinute(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_datetime_minute", "i", "p", pHandle)

func EngineDateTimeSecond(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_datetime_second", "i", "p", pHandle)

func EngineDateTimeAddDays(pHandle, nDays)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_datetime_add_days", "p", "pi",
                     pHandle, nDays)

func EngineDateTimeAddSeconds(pHandle, nSecs)
    if $pEngineHandle = NULL return NULL ok
    return CallCFunc($pEngineHandle, "stz_datetime_add_seconds", "p", "pi",
                     pHandle, nSecs)

func EngineDateTimeToUnix(pHandle)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_datetime_to_unix", "i", "p", pHandle)

func EngineDateTimeToISO(pHandle)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(32)
    nLen = CallCFunc($pEngineHandle, "stz_datetime_to_iso", "i", "ppi",
                     pHandle, cBuf, 32)
    return left(cBuf, nLen)

func EngineDateTimeCompare(pHandle1, pHandle2)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_datetime_compare", "i", "pp",
                     pHandle1, pHandle2)

func EngineDateTimeIsBetween(pHandle, pStart, pEnd)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_datetime_is_between", "i", "ppp",
                     pHandle, pStart, pEnd)

# ════════════════════════════════════════════
# Tier 2: File Functions
# ════════════════════════════════════════════

func EngineFileExists(cPath)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_file_exists", "i", "pi",
                     cPath, len(cPath))

func EngineFileSize(cPath)
    if $pEngineHandle = NULL return -1 ok
    return CallCFunc($pEngineHandle, "stz_file_size", "i", "pi",
                     cPath, len(cPath))

func EngineFileRead(cPath)
    if $pEngineHandle = NULL return "" ok
    nLen = 0
    pData = CallCFunc($pEngineHandle, "stz_file_read", "p", "pip",
                      cPath, len(cPath), :nLen)
    if pData = NULL return "" ok
    cResult = copy(pData, nLen)
    CallCFunc($pEngineHandle, "stz_file_read_free", "v", "pi", pData, nLen)
    return cResult

func EngineFileWrite(cPath, cData)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_file_write", "i", "pipi",
                     cPath, len(cPath), cData, len(cData))

func EngineFileAppend(cPath, cData)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_file_append", "i", "pipi",
                     cPath, len(cPath), cData, len(cData))

func EngineFileDelete(cPath)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_file_delete", "i", "pi",
                     cPath, len(cPath))

func EngineFileCopy(cSrc, cDst)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_file_copy", "i", "pipi",
                     cSrc, len(cSrc), cDst, len(cDst))

func EngineDirExists(cPath)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_dir_exists", "i", "pi",
                     cPath, len(cPath))

func EngineDirCreate(cPath)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_dir_create", "i", "pi",
                     cPath, len(cPath))

func EngineDirCreatePath(cPath)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_dir_create_path", "i", "pi",
                     cPath, len(cPath))

func EngineDirDelete(cPath)
    if $pEngineHandle = NULL return 0 ok
    return CallCFunc($pEngineHandle, "stz_dir_delete", "i", "pi",
                     cPath, len(cPath))

func EngineDirCountFiles(cPath)
    if $pEngineHandle = NULL return -1 ok
    return CallCFunc($pEngineHandle, "stz_dir_count_files", "i", "pi",
                     cPath, len(cPath))

func EngineDirCountDirs(cPath)
    if $pEngineHandle = NULL return -1 ok
    return CallCFunc($pEngineHandle, "stz_dir_count_dirs", "i", "pi",
                     cPath, len(cPath))

func EnginePathExtension(cPath)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(32)
    nLen = CallCFunc($pEngineHandle, "stz_path_extension", "i", "pipi",
                     cPath, len(cPath), cBuf, 32)
    return left(cBuf, nLen)

func EnginePathBasename(cPath)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pEngineHandle, "stz_path_basename", "i", "pipi",
                     cPath, len(cPath), cBuf, 256)
    return left(cBuf, nLen)

func EnginePathDirname(cPath)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pEngineHandle, "stz_path_dirname", "i", "pipi",
                     cPath, len(cPath), cBuf, 256)
    return left(cBuf, nLen)

# ════════════════════════════════════════════
# Tier 2: Locale Functions
# ════════════════════════════════════════════

func EngineLocaleAMText()
    if $pEngineHandle = NULL return "AM" ok
    cBuf = space(4)
    nLen = CallCFunc($pEngineHandle, "stz_locale_am_text", "i", "pi",
                     cBuf, 4)
    return left(cBuf, nLen)

func EngineLocalePMText()
    if $pEngineHandle = NULL return "PM" ok
    cBuf = space(4)
    nLen = CallCFunc($pEngineHandle, "stz_locale_pm_text", "i", "pi",
                     cBuf, 4)
    return left(cBuf, nLen)

func EngineLocaleToUpper(cStr)
    if $pEngineHandle = NULL return upper(cStr) ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pEngineHandle, "stz_locale_to_upper", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)

func EngineLocaleToLower(cStr)
    if $pEngineHandle = NULL return lower(cStr) ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pEngineHandle, "stz_locale_to_lower", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)

func EngineLocaleToTitlecase(cStr)
    if $pEngineHandle = NULL return cStr ok
    cBuf = space(len(cStr))
    nLen = CallCFunc($pEngineHandle, "stz_locale_to_titlecase", "i", "pipi",
                     cStr, len(cStr), cBuf, len(cStr))
    return left(cBuf, nLen)

func EngineLocaleFormatNumber(nValue, nDecimals)
    if $pEngineHandle = NULL return "" + nValue ok
    cBuf = space(32)
    nLen = CallCFunc($pEngineHandle, "stz_locale_format_number", "i", "dipi",
                     nValue, nDecimals, cBuf, 32)
    return left(cBuf, nLen)

func EngineLocaleMonthName(nMonth)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pEngineHandle, "stz_locale_month_name", "i", "ipi",
                     nMonth, cBuf, 16)
    return left(cBuf, nLen)

func EngineLocaleMonthAbbr(nMonth)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(8)
    nLen = CallCFunc($pEngineHandle, "stz_locale_month_abbr", "i", "ipi",
                     nMonth, cBuf, 8)
    return left(cBuf, nLen)

func EngineLocaleDayName(nDow)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pEngineHandle, "stz_locale_day_name", "i", "ipi",
                     nDow, cBuf, 16)
    return left(cBuf, nLen)

func EngineLocaleDayAbbr(nDow)
    if $pEngineHandle = NULL return "" ok
    cBuf = space(8)
    nLen = CallCFunc($pEngineHandle, "stz_locale_day_abbr", "i", "ipi",
                     nDow, cBuf, 8)
    return left(cBuf, nLen)

# ════════════════════════════════════════════
# Engine Version
# ════════════════════════════════════════════

func EngineVersion()
    if $pEngineHandle = NULL return "0.0.0 (not loaded)" ok
    nVer = CallCFunc($pEngineHandle, "stz_engine_version", "i", "")
    nMajor = floor(nVer / 0x01000000)
    nMinor = floor((nVer % 0x01000000) / 0x010000)
    nPatch = floor((nVer % 0x010000) / 0x0100)
    return "" + nMajor + "." + nMinor + "." + nPatch
