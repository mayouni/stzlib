# Softanza Engine -- Base DateTime Ring Bridge
#
# Loads stz_datetime.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
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

#------------------------------------------------------------#
#  HIGH-LEVEL DATE WRAPPERS                                  #
#  Bridge unused engine exports into production Ring API     #
#------------------------------------------------------------#

func StzDaysInMonth(nYear, nMonth)
    pHandle = StzEngineDateNew(nYear, nMonth, 1)
    nResult = StzEngineDateDaysInMonth(pHandle)
    StzEngineDateFree(pHandle)
    return nResult

func StzDaysInYear(nYear)
    pHandle = StzEngineDateNew(nYear, 1, 1)
    nResult = StzEngineDateDaysInYear(pHandle)
    StzEngineDateFree(pHandle)
    return nResult

func StzIsLeapYear(nYear)
    pHandle = StzEngineDateNew(nYear, 1, 1)
    nResult = StzEngineDateIsLeapYear(pHandle)
    StzEngineDateFree(pHandle)
    return nResult

func StzDateToString(nYear, nMonth, nDay)
    pHandle = StzEngineDateNew(nYear, nMonth, nDay)
    cResult = StzEngineDateToString(pHandle)
    StzEngineDateFree(pHandle)
    return cResult

func StzDateToISO(nYear, nMonth, nDay)
    pHandle = StzEngineDateNew(nYear, nMonth, nDay)
    cResult = StzEngineDateToISO(pHandle)
    StzEngineDateFree(pHandle)
    return cResult

func StzDateFormat(nYear, nMonth, nDay, cFormat)
    pHandle = StzEngineDateNew(nYear, nMonth, nDay)
    cResult = StzEngineDateFormat(pHandle, cFormat)
    StzEngineDateFree(pHandle)
    return cResult

func StzCompareDates(nY1, nM1, nD1, nY2, nM2, nD2)
    pH1 = StzEngineDateNew(nY1, nM1, nD1)
    pH2 = StzEngineDateNew(nY2, nM2, nD2)
    nResult = StzEngineDateCompare(pH1, pH2)
    StzEngineDateFree(pH2)
    StzEngineDateFree(pH1)
    return nResult

#------------------------------------------------------------#
#  HIGH-LEVEL TIME WRAPPERS                                  #
#------------------------------------------------------------#

func StzTimeNew(nHour, nMinute, nSecond)
    return StzEngineTimeNew(nHour, nMinute, nSecond)

func StzTimeNewMs(nHour, nMinute, nSecond, nMs)
    return StzEngineTimeNewMs(nHour, nMinute, nSecond, nMs)

func StzTimeHour12(pHandle)
    return StzEngineTimeHour12(pHandle)

func StzTimeIsPm(pHandle)
    return StzEngineTimeIsPm(pHandle)

func StzTimeAddSeconds(pHandle, nSeconds)
    return StzEngineTimeAddSeconds(pHandle, nSeconds)

func StzTimeAddMs(pHandle, nMs)
    return StzEngineTimeAddMs(pHandle, nMs)

func StzTimeToString(nHour, nMinute, nSecond)
    pHandle = StzEngineTimeNew(nHour, nMinute, nSecond)
    cResult = StzEngineTimeToString(pHandle)
    StzEngineTimeFree(pHandle)
    return cResult

func StzTimeToString12h(nHour, nMinute, nSecond)
    pHandle = StzEngineTimeNew(nHour, nMinute, nSecond)
    cResult = StzEngineTimeToString12h(pHandle)
    StzEngineTimeFree(pHandle)
    return cResult

func StzCompareTimes(nH1, nM1, nS1, nH2, nM2, nS2)
    pH1 = StzEngineTimeNew(nH1, nM1, nS1)
    pH2 = StzEngineTimeNew(nH2, nM2, nS2)
    nResult = StzEngineTimeCompare(pH1, pH2)
    StzEngineTimeFree(pH2)
    StzEngineTimeFree(pH1)
    return nResult

#------------------------------------------------------------#
#  HIGH-LEVEL DATETIME WRAPPERS                              #
#------------------------------------------------------------#

func StzCompareDateTimes(nY1, nM1, nD1, nH1, nMi1, nS1, nY2, nM2, nD2, nH2, nMi2, nS2)
    pH1 = StzEngineDateTimeNew(nY1, nM1, nD1, nH1, nMi1, nS1)
    pH2 = StzEngineDateTimeNew(nY2, nM2, nD2, nH2, nMi2, nS2)
    nResult = StzEngineDateTimeCompare(pH1, pH2)
    StzEngineDateTimeFree(pH2)
    StzEngineDateTimeFree(pH1)
    return nResult

func StzDateTimeIsBetween(nY, nM, nD, nH, nMi, nS, nY1, nM1, nD1, nH1, nMi1, nS1, nY2, nM2, nD2, nH2, nMi2, nS2)
    pMain = StzEngineDateTimeNew(nY, nM, nD, nH, nMi, nS)
    pLow  = StzEngineDateTimeNew(nY1, nM1, nD1, nH1, nMi1, nS1)
    pHigh = StzEngineDateTimeNew(nY2, nM2, nD2, nH2, nMi2, nS2)
    nResult = StzEngineDateTimeIsBetween(pMain, pLow, pHigh)
    StzEngineDateTimeFree(pHigh)
    StzEngineDateTimeFree(pLow)
    StzEngineDateTimeFree(pMain)
    return nResult

func StzDateTimeToISO(nYear, nMonth, nDay, nHour, nMinute, nSecond)
    pHandle = StzEngineDateTimeNew(nYear, nMonth, nDay, nHour, nMinute, nSecond)
    cResult = StzEngineDateTimeToISO(pHandle)
    StzEngineDateTimeFree(pHandle)
    return cResult
