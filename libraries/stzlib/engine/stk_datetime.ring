# Softanza Engine -- Core DateTime FFI Bridge
#
# Loads stk_datetime.dll -- lifecycle, components, compare only.
# Used by: core/datetime/stkDate.ring, stkTime.ring

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

func EngineDateNew(nYear, nMonth, nDay)
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_new", "p", "iii",
                     nYear, nMonth, nDay)

func EngineDateToday()
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_today", "p", "")

func EngineDateFree(pHandle)
    if $pStkDateTimeHandle = NULL return ok
    CallCFunc($pStkDateTimeHandle, "stz_date_free", "v", "p", pHandle)

func EngineDateYear(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_year", "i", "p", pHandle)

func EngineDateMonth(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_month", "i", "p", pHandle)

func EngineDateDay(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_day", "i", "p", pHandle)

func EngineDateCompare(pHandle1, pHandle2)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_date_compare", "i", "pp",
                     pHandle1, pHandle2)

# ── Core Time Functions ──

func EngineTimeNew(nHour, nMinute, nSecond)
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_new", "p", "iii",
                     nHour, nMinute, nSecond)

func EngineTimeNow()
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_now", "p", "")

func EngineTimeFree(pHandle)
    if $pStkDateTimeHandle = NULL return ok
    CallCFunc($pStkDateTimeHandle, "stz_time_free", "v", "p", pHandle)

func EngineTimeHour(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_hour", "i", "p", pHandle)

func EngineTimeMinute(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_minute", "i", "p", pHandle)

func EngineTimeSecond(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_second", "i", "p", pHandle)

func EngineTimeCompare(pHandle1, pHandle2)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_time_compare", "i", "pp",
                     pHandle1, pHandle2)

# ── Core DateTime Functions ──

func EngineDateTimeNew(nYear, nMonth, nDay, nHour, nMinute, nSecond)
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_new", "p", "iiiiii",
                     nYear, nMonth, nDay, nHour, nMinute, nSecond)

func EngineDateTimeNow()
    if $pStkDateTimeHandle = NULL return NULL ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_now", "p", "")

func EngineDateTimeFree(pHandle)
    if $pStkDateTimeHandle = NULL return ok
    CallCFunc($pStkDateTimeHandle, "stz_datetime_free", "v", "p", pHandle)

func EngineDateTimeYear(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_year", "i", "p", pHandle)

func EngineDateTimeMonth(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_month", "i", "p", pHandle)

func EngineDateTimeDay(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_day", "i", "p", pHandle)

func EngineDateTimeHour(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_hour", "i", "p", pHandle)

func EngineDateTimeMinute(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_minute", "i", "p", pHandle)

func EngineDateTimeSecond(pHandle)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_second", "i", "p", pHandle)

func EngineDateTimeCompare(pHandle1, pHandle2)
    if $pStkDateTimeHandle = NULL return 0 ok
    return CallCFunc($pStkDateTimeHandle, "stz_datetime_compare", "i", "pp",
                     pHandle1, pHandle2)
