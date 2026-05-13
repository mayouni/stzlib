# Softanza Engine -- DateTime FFI Bridge
#
# Loads stz_datetime.dll/.so and wraps each C function.
# Used by: base/datetime/stzDate.ring, stzTime.ring, stzDateTime.ring

if isWindows()
    $cStzDateTimeLib = currentdir() + "/zig-out/bin/stz_datetime.dll"
but isLinux()
    $cStzDateTimeLib = currentdir() + "/zig-out/lib/libstz_datetime.so"
but isMacOS()
    $cStzDateTimeLib = currentdir() + "/zig-out/lib/libstz_datetime.dylib"
ok

if fexists($cStzDateTimeLib)
    $pStzDateTimeHandle = LoadLib($cStzDateTimeLib)
else
    ? "WARNING: stz_datetime not found at: " + $cStzDateTimeLib
    $pStzDateTimeHandle = NULL
ok

# ── Date Functions ──

func EngineDateNew(nYear, nMonth, nDay)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_new", "p", "iii",
                     nYear, nMonth, nDay)

func EngineDateToday()
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_today", "p", "")

func EngineDateFree(pHandle)
    if $pStzDateTimeHandle = NULL return ok
    CallCFunc($pStzDateTimeHandle, "stz_date_free", "v", "p", pHandle)

func EngineDateYear(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_year", "i", "p", pHandle)

func EngineDateMonth(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_month", "i", "p", pHandle)

func EngineDateDay(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_day", "i", "p", pHandle)

func EngineDateDayOfWeek(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_day_of_week", "i", "p", pHandle)

func EngineDateDayOfYear(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_day_of_year", "i", "p", pHandle)

func EngineDateDaysInMonth(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_days_in_month", "i", "p", pHandle)

func EngineDateDaysInYear(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_days_in_year", "i", "p", pHandle)

func EngineDateIsLeapYear(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_is_leap_year", "i", "p", pHandle)

func EngineDateAddDays(pHandle, nDays)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_add_days", "p", "pi",
                     pHandle, nDays)

func EngineDateDiffDays(pHandle1, pHandle2)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_diff_days", "i", "pp",
                     pHandle1, pHandle2)

func EngineDateToString(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(32)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_date_to_string", "i", "ppi",
                     pHandle, cBuf, 32)
    return left(cBuf, nLen)

func EngineDateToISO(pHandle)
    return EngineDateToString(pHandle)

func EngineDateCompare(pHandle1, pHandle2)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_compare", "i", "pp",
                     pHandle1, pHandle2)

func EngineDateDayName(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_date_day_name", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

func EngineDateMonthName(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_date_month_name", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

# ── Time Functions ──

func EngineTimeNew(nHour, nMinute, nSecond)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_new", "p", "iii",
                     nHour, nMinute, nSecond)

func EngineTimeNewMs(nHour, nMinute, nSecond, nMs)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_new_ms", "p", "iiii",
                     nHour, nMinute, nSecond, nMs)

func EngineTimeNow()
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_now", "p", "")

func EngineTimeFree(pHandle)
    if $pStzDateTimeHandle = NULL return ok
    CallCFunc($pStzDateTimeHandle, "stz_time_free", "v", "p", pHandle)

func EngineTimeHour(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_hour", "i", "p", pHandle)

func EngineTimeMinute(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_minute", "i", "p", pHandle)

func EngineTimeSecond(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_second", "i", "p", pHandle)

func EngineTimeMillisecond(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_millisecond", "i", "p", pHandle)

func EngineTimeHour12(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_hour12", "i", "p", pHandle)

func EngineTimeIsPM(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_is_pm", "i", "p", pHandle)

func EngineTimeAddSeconds(pHandle, nSecs)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_add_seconds", "p", "pi",
                     pHandle, nSecs)

func EngineTimeToString(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_time_to_string", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

func EngineTimeTo12h(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_time_to_string_12h", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

func EngineTimeCompare(pHandle1, pHandle2)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_compare", "i", "pp",
                     pHandle1, pHandle2)

# ── DateTime Functions ──

func EngineDateTimeNew(nYear, nMonth, nDay, nHour, nMinute, nSecond)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_new", "p", "iiiiii",
                     nYear, nMonth, nDay, nHour, nMinute, nSecond)

func EngineDateTimeNow()
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_now", "p", "")

func EngineDateTimeFromUnix(nTimestamp)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_from_unix", "p", "i",
                     nTimestamp)

func EngineDateTimeFree(pHandle)
    if $pStzDateTimeHandle = NULL return ok
    CallCFunc($pStzDateTimeHandle, "stz_datetime_free", "v", "p", pHandle)

func EngineDateTimeYear(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_year", "i", "p", pHandle)

func EngineDateTimeMonth(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_month", "i", "p", pHandle)

func EngineDateTimeDay(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_day", "i", "p", pHandle)

func EngineDateTimeHour(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_hour", "i", "p", pHandle)

func EngineDateTimeMinute(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_minute", "i", "p", pHandle)

func EngineDateTimeSecond(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_second", "i", "p", pHandle)

func EngineDateTimeAddDays(pHandle, nDays)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_add_days", "p", "pi",
                     pHandle, nDays)

func EngineDateTimeAddSeconds(pHandle, nSecs)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_add_seconds", "p", "pi",
                     pHandle, nSecs)

func EngineDateTimeToUnix(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_to_unix", "i", "p", pHandle)

func EngineDateTimeToISO(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(32)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_datetime_to_iso", "i", "ppi",
                     pHandle, cBuf, 32)
    return left(cBuf, nLen)

func EngineDateTimeCompare(pHandle1, pHandle2)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_compare", "i", "pp",
                     pHandle1, pHandle2)

func EngineDateTimeIsBetween(pHandle, pStart, pEnd)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_is_between", "i", "ppp",
                     pHandle, pStart, pEnd)
