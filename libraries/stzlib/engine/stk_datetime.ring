# Softanza Engine -- Core DateTime FFI Bridge
#
# Loads stk_datetime.dll -- lifecycle, components, compare only.
# Used by: core/datetime/stkDate.ring, stkTime.ring
# Function prefix: StkEngine* (distinct from Base StzEngine*)

if isWindows()
    $cStkDateTimeLib = currentdir() + "/zig-out/bin/stk_datetime.dll"
but isLinux()
    $cStkDateTimeLib = currentdir() + "/zig-out/lib/libstk_datetime.so"
but isMacOS()
    $cStkDateTimeLib = currentdir() + "/zig-out/lib/libstk_datetime.dylib"
ok

if fexists($cStkDateTimeLib)
    $pStkDateTimeHandle = LoadLib($cStkDateTimeLib)
else
    ? "WARNING: stk_datetime not found at: " + $cStkDateTimeLib
    $pStkDateTimeHandle = NULL
ok

# ── Core Date Functions ──

func StkEngineDateNew(nYear, nMonth, nDay)
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_new", "p", "iii",
                     nYear, nMonth, nDay)

func StkEngineDateToday()
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_today", "p", "")

func StkEngineDateFree(pHandle)
    if $pStkDateTimeHandle = NULL return ok
    CallCFunc($pStkDateTimeHandle, "stz_date_free", "v", "p", pHandle)

func StkEngineDateYear(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_year", "i", "p", pHandle)

func StkEngineDateMonth(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_month", "i", "p", pHandle)

func StkEngineDateDay(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_day", "i", "p", pHandle)

func StkEngineDateCompare(pHandle1, pHandle2)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_compare", "i", "pp",
                     pHandle1, pHandle2)

# ── Core Time Functions ──

func StkEngineTimeNew(nHour, nMinute, nSecond)
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_new", "p", "iii",
                     nHour, nMinute, nSecond)

func StkEngineTimeNow()
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_now", "p", "")

func StkEngineTimeFree(pHandle)
    if $pStkDateTimeHandle = NULL return ok
    CallCFunc($pStkDateTimeHandle, "stz_time_free", "v", "p", pHandle)

func StkEngineTimeHour(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_hour", "i", "p", pHandle)

func StkEngineTimeMinute(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_minute", "i", "p", pHandle)

func StkEngineTimeSecond(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_second", "i", "p", pHandle)

func StkEngineTimeCompare(pHandle1, pHandle2)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_compare", "i", "pp",
                     pHandle1, pHandle2)

# ── Core DateTime Functions ──

func StkEngineDateTimeNew(nYear, nMonth, nDay, nHour, nMinute, nSecond)
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_new", "p", "iiiiii",
                     nYear, nMonth, nDay, nHour, nMinute, nSecond)

func StkEngineDateTimeNow()
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_now", "p", "")

func StkEngineDateTimeFree(pHandle)
    if $pStkDateTimeHandle = NULL return ok
    CallCFunc($pStkDateTimeHandle, "stz_datetime_free", "v", "p", pHandle)

func StkEngineDateTimeYear(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_year", "i", "p", pHandle)

func StkEngineDateTimeMonth(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_month", "i", "p", pHandle)

func StkEngineDateTimeDay(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_day", "i", "p", pHandle)

func StkEngineDateTimeHour(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_hour", "i", "p", pHandle)

func StkEngineDateTimeMinute(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_minute", "i", "p", pHandle)

func StkEngineDateTimeSecond(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_second", "i", "p", pHandle)

func StkEngineDateTimeCompare(pHandle1, pHandle2)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_compare", "i", "pp",
                     pHandle1, pHandle2)
