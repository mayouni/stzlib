# Softanza Engine -- Base DateTime FFI Bridge
#
# Loads stz_datetime.dll -- full features, superset of Core.
# Used by: base/datetime/stzDate.ring, stzTime.ring, stzDateTime.ring
# Function prefix: StzEngine* (distinct from Core StkEngine*)

if isWindows()
    $cStzDateTimeLib = $cEngineDir + "/zig-out/bin/stz_datetime.dll"
but isLinux()
    $cStzDateTimeLib = $cEngineDir + "/zig-out/lib/libstz_datetime.so"
but isMacOS()
    $cStzDateTimeLib = $cEngineDir + "/zig-out/lib/libstz_datetime.dylib"
ok

if fexists($cStzDateTimeLib)
    $pStzDateTimeHandle = LoadLib($cStzDateTimeLib)
else
    ? "WARNING: stz_datetime not found at: " + $cStzDateTimeLib
    $pStzDateTimeHandle = NULL
ok

# ── Date Lifecycle + Components (from Core) ──

func StzEngineDateNew(nYear, nMonth, nDay)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_new", "p", "iii",
                     nYear, nMonth, nDay)

func StzEngineDateToday()
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_today", "p", "")

func StzEngineDateFree(pHandle)
    if $pStzDateTimeHandle = NULL return ok
    CallCFunc($pStzDateTimeHandle, "stz_date_free", "v", "p", pHandle)

func StzEngineDateYear(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_year", "i", "p", pHandle)

func StzEngineDateMonth(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_month", "i", "p", pHandle)

func StzEngineDateDay(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_day", "i", "p", pHandle)

func StzEngineDateCompare(pHandle1, pHandle2)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_compare", "i", "pp",
                     pHandle1, pHandle2)

# ── Date Extended (Base only) ──

func StzEngineDateDayOfWeek(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_day_of_week", "i", "p", pHandle)

func StzEngineDateDayOfYear(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_day_of_year", "i", "p", pHandle)

func StzEngineDateDaysInMonth(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_days_in_month", "i", "p", pHandle)

func StzEngineDateDaysInYear(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_days_in_year", "i", "p", pHandle)

func StzEngineDateIsLeapYear(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_is_leap_year", "i", "p", pHandle)

func StzEngineDateAddDays(pHandle, nDays)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_add_days", "p", "pi",
                     pHandle, nDays)

func StzEngineDateDiffDays(pHandle1, pHandle2)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_date_diff_days", "i", "pp",
                     pHandle1, pHandle2)

func StzEngineDateToString(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(32)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_date_to_string", "i", "ppi",
                     pHandle, cBuf, 32)
    return left(cBuf, nLen)

func StzEngineDateToISO(pHandle)
    return StzEngineDateToString(pHandle)

func StzEngineDateDayName(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_date_day_name", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

func StzEngineDateMonthName(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_date_month_name", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

# ── Time Lifecycle + Components (from Core) ──

func StzEngineTimeNew(nHour, nMinute, nSecond)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_new", "p", "iii",
                     nHour, nMinute, nSecond)

func StzEngineTimeNow()
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_now", "p", "")

func StzEngineTimeFree(pHandle)
    if $pStzDateTimeHandle = NULL return ok
    CallCFunc($pStzDateTimeHandle, "stz_time_free", "v", "p", pHandle)

func StzEngineTimeHour(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_hour", "i", "p", pHandle)

func StzEngineTimeMinute(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_minute", "i", "p", pHandle)

func StzEngineTimeSecond(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_second", "i", "p", pHandle)

func StzEngineTimeCompare(pHandle1, pHandle2)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_compare", "i", "pp",
                     pHandle1, pHandle2)

# ── Time Extended (Base only) ──

func StzEngineTimeNewMs(nHour, nMinute, nSecond, nMs)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_new_ms", "p", "iiii",
                     nHour, nMinute, nSecond, nMs)

func StzEngineTimeMillisecond(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_millisecond", "i", "p", pHandle)

func StzEngineTimeHour12(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_hour12", "i", "p", pHandle)

func StzEngineTimeIsPM(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_is_pm", "i", "p", pHandle)

func StzEngineTimeAddSeconds(pHandle, nSecs)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_time_add_seconds", "p", "pi",
                     pHandle, nSecs)

func StzEngineTimeToString(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_time_to_string", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

func StzEngineTimeTo12h(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(16)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_time_to_string_12h", "i", "ppi",
                     pHandle, cBuf, 16)
    return left(cBuf, nLen)

# ── DateTime Lifecycle + Components (from Core) ──

func StzEngineDateTimeNew(nYear, nMonth, nDay, nHour, nMinute, nSecond)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_new", "p", "iiiiii",
                     nYear, nMonth, nDay, nHour, nMinute, nSecond)

func StzEngineDateTimeNow()
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_now", "p", "")

func StzEngineDateTimeFree(pHandle)
    if $pStzDateTimeHandle = NULL return ok
    CallCFunc($pStzDateTimeHandle, "stz_datetime_free", "v", "p", pHandle)

func StzEngineDateTimeYear(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_year", "i", "p", pHandle)

func StzEngineDateTimeMonth(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_month", "i", "p", pHandle)

func StzEngineDateTimeDay(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_day", "i", "p", pHandle)

func StzEngineDateTimeHour(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_hour", "i", "p", pHandle)

func StzEngineDateTimeMinute(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_minute", "i", "p", pHandle)

func StzEngineDateTimeSecond(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_second", "i", "p", pHandle)

func StzEngineDateTimeCompare(pHandle1, pHandle2)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_compare", "i", "pp",
                     pHandle1, pHandle2)

# ── DateTime Extended (Base only) ──

func StzEngineDateTimeFromUnix(nTimestamp)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_from_unix", "p", "i",
                     nTimestamp)

func StzEngineDateTimeAddDays(pHandle, nDays)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_add_days", "p", "pi",
                     pHandle, nDays)

func StzEngineDateTimeAddSeconds(pHandle, nSecs)
    if $pStzDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_add_seconds", "p", "pi",
                     pHandle, nSecs)

func StzEngineDateTimeToUnix(pHandle)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_to_unix", "i", "p", pHandle)

func StzEngineDateTimeToISO(pHandle)
    if $pStzDateTimeHandle = NULL return "" ok
    cBuf = space(32)
    nLen = CallCFunc($pStzDateTimeHandle, "stz_datetime_to_iso", "i", "ppi",
                     pHandle, cBuf, 32)
    return left(cBuf, nLen)

func StzEngineDateTimeIsBetween(pHandle, pStart, pEnd)
    if $pStzDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStzDateTimeHandle, "stz_datetime_is_between", "i", "ppp",
                     pHandle, pStart, pEnd)
