
#TODO Make a bridge with stzLocale to let the stzDate class be locale-sensitive

# Multi-language day names
$aDayNames = [
    [ :English, [ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" ] ],
    [ :French, [ "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche" ] ],
    [ :Arabic, [ "Ø§Ù„Ø§Ø«Ù†ÙŠÙ†", "Ø§Ù„Ø«Ù„Ø§Ø«Ø§Ø¡", "Ø§Ù„Ø£Ø±Ø¨Ø¹Ø§Ø¡", "Ø§Ù„Ø®Ù…ÙŠØ³", "Ø§Ù„Ø¬Ù…Ø¹Ø©", "Ø§Ù„Ø³Ø¨Øª", "Ø§Ù„Ø£Ø­Ø¯" ] ]
]

# Multi-language month names
$aMonthNames = [
    [ :English, [ "January", "February", "March", "April", "May", "June",
                 "July", "August", "September", "October", "November", "December" ] ],
    [ :French, [ "Janvier", "FÃ©vrier", "Mars", "Avril", "Mai", "Juin",
                "Juillet", "AoÃ»t", "Septembre", "Octobre", "Novembre", "DÃ©cembre" ] ],
    [ :Arabic, [ "ÙŠÙ†Ø§ÙŠØ±", "ÙØ¨Ø±Ø§ÙŠØ±", "Ù…Ø§Ø±Ø³", "Ø£Ø¨Ø±ÙŠÙ„", "Ù…Ø§ÙŠÙˆ", "ÙŠÙˆÙ†ÙŠÙˆ",
                "ÙŠÙˆÙ„ÙŠÙˆ", "Ø£ØºØ³Ø·Ø³", "Ø³Ø¨ØªÙ…Ø¨Ø±", "Ø£ÙƒØªÙˆØ¨Ø±", "Ù†ÙˆÙÙ…Ø¨Ø±", "Ø¯ÙŠØ³Ù…Ø¨Ø±" ] ]
]

# Default language
$cCurrentLanguage = :English

$cDefaultDateFormat = "dd/MM/yyyy"
$cDefaultTimeFormat = "hh:mm:ss"
$cDefaultDateTimeFormat = "dd/MM/yyyy hh:mm:ss"

$aDateFormats = [
    [ :ISO8601, "yyyy-MM-dd" ],
    [ :European, "dd/MM/yyyy" ],
    [ :American, "MM/dd/yyyy" ],
    [ :Compact, "ddMMyyyy" ],
    [ :Long, "dddd, MMMM d, yyyy" ]
]

$aTimeFormats = [
    [ :Standard, "hh:mm:ss" ],
    [ :Short, "hh:mm" ],
    [ :WithMs, "hh:mm:ss.zzz" ],
    [ :AmPm, "h:mm:ss AP" ],
    [ :Military, "HH:mm:ss" ]
]

$aCommonDateParsers = [
    [ "today", "NOW" ],
    [ "yesterday", "NOW-1" ],
    [ "tomorrow", "NOW+1" ]
]

$aRelativeDateKeywords = [
    [ "next monday", "NEXT_MONDAY" ],
    [ "last friday", "LAST_FRIDAY" ],
    [ "end of month", "END_OF_MONTH" ],
    [ "start of month", "START_OF_MONTH" ],
    [ "end of year", "END_OF_YEAR" ],
    [ "start of year", "START_OF_YEAR" ]
]

func _DaysInMonth(nYear, nMonth)
    aMonthDays = [31,28,31,30,31,30,31,31,30,31,30,31]
    if nMonth = 2 and _IsLeapYear(nYear) return 29 ok
    return aMonthDays[nMonth]

func _IsLeapYear(nYear)
    if nYear % 400 = 0 return TRUE ok
    if nYear % 100 = 0 return FALSE ok
    if nYear % 4 = 0 return TRUE ok
    return FALSE

func _DateAddMonths(nYear, nMonth, nDay, nMonths)
    nMonth += nMonths
    while nMonth > 12
        nMonth -= 12
        nYear++
    end
    while nMonth < 1
        nMonth += 12
        nYear--
    end
    nMaxDay = _DaysInMonth(nYear, nMonth)
    if nDay > nMaxDay nDay = nMaxDay ok
    return [nYear, nMonth, nDay]

func _DateAddYears(nYear, nMonth, nDay, nYears)
    nYear += nYears
    nMaxDay = _DaysInMonth(nYear, nMonth)
    if nDay > nMaxDay nDay = nMaxDay ok
    return [nYear, nMonth, nDay]

func _DateFormatString(nYear, nMonth, nDay, cFormat)
    pHandle = StzEngineDateNew(nYear, nMonth, nDay)
    cDayName = StzEngineDateDayName(pHandle)
    cMonthName = StzEngineDateMonthName(pHandle)
    StzEngineDateFree(pHandle)

    cResult = cFormat
    cResult = StzReplace(cResult, "dddd", cDayName)
    cResult = StzReplace(cResult, "ddd", StzLeft(cDayName, 3))
    cResult = StzReplace(cResult, "dd", _PadLeft("" + nDay, 2, "0"))
    cResult = StzReplace(cResult, "MMMM", cMonthName)
    cResult = StzReplace(cResult, "MMM", StzLeft(cMonthName, 3))
    cResult = StzReplace(cResult, "MM", _PadLeft("" + nMonth, 2, "0"))
    cResult = StzReplace(cResult, "yyyy", "" + nYear)
    nYY = nYear % 100
    cResult = StzReplace(cResult, "yy", _PadLeft("" + nYY, 2, "0"))
    return cResult

func _PadLeft(cStr, nWidth, cPadChar)
    while len(cStr) < nWidth
        cStr = cPadChar + cStr
    end
    return cStr

func _TodayYMD()
    pHandle = StzEngineDateToday()
    nY = StzEngineDateYear(pHandle)
    nM = StzEngineDateMonth(pHandle)
    nD = StzEngineDateDay(pHandle)
    StzEngineDateFree(pHandle)
    return [nY, nM, nD]

func _IsValidDate(nYear, nMonth, nDay)
    if nMonth < 1 or nMonth > 12 return FALSE ok
    if nDay < 1 or nDay > _DaysInMonth(nYear, nMonth) return FALSE ok
    return TRUE

func StzTimeStamp()
	return Date() + " " + Time()

	func TimeStamp()
		return StzTimeStamp()

# Quick date creation functions
func StzYesterday()
    return StzDateQ("").SubtractDaysQ(1).Content()

	func Yesterday()
		return StzYesterday()

func StzTomorrow()
    return StzDateQ("").AddDaysQ(1).Content()

	func Tomorrow()
		return StzTomorrow()

func StzStartOfWeek()
    oDate = StzDateQ("")
    nDaysToSubtract = oDate.DayOfWeekN() - 1
    return oDate.SubtractDaysQ(nDaysToSubtract).Content()

	func StartOfWeek()
		return StzStartOfWeek()

func StzEndOfWeek()
    oDate = StzStartOfWeek()
    return oDate.AddDaysQ(6).Content()

	func EndOfWeek()
		return StzEndOfWeek()

func StzStartOfMonth()
    oDate = StzDateQ("")
    return StzDateQ("01/" + oDate.MonthNumberInString() + "/" + oDate.Year()).Content()

	func StartOfMonth()
		return StzStartOfMonth()

func StzEndOfMonth()
    oDate = StzDateQ("")
    nDays = oDate.DaysInMonthN()
    return StzDateQ('' + nDays + "/" + oDate.MonthNumberInString() + "/" + oDate.Year()).Content()

	func EndOfMonth()
		return StzEndOfMonth()


#=== UTILITY FUNCTIONS ===#

func StzGetDayByName(nDayOfWeek)
	return StzGetDayNameXT(nDayOfWeek, :English)

	func GetDayByName(nDayOfWeek)
		return StzGetDayByName(nDayOfWeek)

func StzGetDayName(nDayOfWeek)
	return StzGetDayNameXT(nDayOfWeek, :English)

	func GetDayName(nDayOfWeek)
		return StzGetDayName(nDayOfWeek)

func StzGetDayNameXT(nDayOfWeek, cLanguage)
    if cLanguage = NULL
        cLanguage = $cCurrentLanguage
    ok

    for aLang in $aDayNames
        if aLang[1] = cLanguage
            return aLang[2][nDayOfWeek]
        ok
    next

    for aLang in $aDayNames
        if aLang[1] = :English
            return aLang[2][nDayOfWeek]
        ok
    next

	func GetDayNameXT(nDayOfWeek, cLanguage)
		return StzGetDayNameXT(nDayOfWeek, cLanguage)

	func StzGetDayNameInLanguage(nDayOfWeek, cLanguage)
		return StzGetDayNameXT(nDayOfWeek, cLanguage)

	func GetDayNameInLanguage(nDayOfWeek, cLanguage)
		return StzGetDayNameXT(nDayOfWeek, cLanguage)

func StzGetMonthName(nMonth)
	return StzGetMonthNameInLanguage(nMonth, :English)

	func GetMonthName(nMonth)
		return StzGetMonthName(nMonth)

func StzGetMonthNameInLanguage(nMonth, cLanguage)
    if cLanguage = NULL
        cLanguage = $cCurrentLanguage
    ok

    for aLang in $aMonthNames
        if aLang[1] = cLanguage
            return aLang[2][nMonth]
        ok
    next

    for aLang in $aMonthNames
        if aLang[1] = :English
            return aLang[2][nMonth]
        ok
    next

	func GetMonthNameInLanguage(nMonth, cLanguage)
		return StzGetMonthNameInLanguage(nMonth, cLanguage)

	func StzGetMonthNameXT(nMonth, cLanguage)
		return StzGetMonthNameInLanguage(nMonth, cLanguage)

	func GetMonthNameXT(nMonth, cLanguage)
		return StzGetMonthNameInLanguage(nMonth, cLanguage)

func StzSysDate()
	return date()

	func SysDate()
		return StzSysDate()

	func StzDateSys()
		return StzSysDate()

	func DateSys()
		return StzSysDate()

func StzAddDays(cDate, n)
	return addDays(cDate, n)

	func ring_addDays(cDate, n)
		return StzAddDays(cDate, n)

func StzDateQ(pDate)
    return new stzDate(pDate)

func StzNow()
	return Date() + " " + Time()

	func Now()
		return StzNow()

func StzTodayQ()
    return StzDateQ(StzDateSys())

	func TodayQ()
		return StzTodayQ()

	func StzToday()
		return StzTodayQ().ToString()

	func Today()
		return StzToday()

func StzIsDate(str)
	Rx = Rx(pat(:Date))
	return Rx.Match(str)

	func IsDate(str)
		return StzIsDate(str)

	func StzIsValidDate(str)
		return StzIsDate(str)

	func IsValidDate(str)
		return StzIsDate(str)

func StzDayOrdinalSuffix(nDay)
    if nDay % 10 = 1 and nDay != 11
        return "st"
    but nDay % 10 = 2 and nDay != 12
        return "nd"
    but nDay % 10 = 3 and nDay != 13
        return "rd"
    else
        return "th"
    ok

	func DayOrdinalSuffix(nDay)
		return StzDayOrdinalSuffix(nDay)

class stzDate from stzObject
    @nYear
    @nMonth
    @nDay

    	def init(pcDate)
		This.SetDate(pcDate)

	def SetDate(pcDate)
	    if isList(pcDate) and len(pcDate) = 3
	        if IsListOfNumbers(pcDate)
		    @nYear = pcDate[1]
		    @nMonth = pcDate[2]
		    @nDay = pcDate[3]
		    return

	        but IsHashList(pcDate) and HasKeys(pcDate, [ :Year, :Month, :Day ])
		    @nYear = pcDate[:Year]
		    @nMonth = pcDate[:Month]
		    @nDay = pcDate[:Day]
		    return
	        ok
	    ok

	    if NOT isString(pcDate)
	        StzRaise("Can't create the stzDate object! You must provide a string.")
	    ok

	    cDate = StzLower(trim(pcDate))
	    nLenDate = len(cDate)


	    if cDate = ''
	        aToday = _TodayYMD()
	        @nYear = aToday[1]
	        @nMonth = aToday[2]
	        @nDay = aToday[3]
	        return

	    but cDate = "today"
	        aToday = _TodayYMD()
	        @nYear = aToday[1]
	        @nMonth = aToday[2]
	        @nDay = aToday[3]
	        return

	    but cDate = "yesterday"
	        aToday = _TodayYMD()
	        pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
	        pNew = StzEngineDateAddDays(pHandle, -1)
	        @nYear = StzEngineDateYear(pNew)
	        @nMonth = StzEngineDateMonth(pNew)
	        @nDay = StzEngineDateDay(pNew)
	        StzEngineDateFree(pNew)
	        StzEngineDateFree(pHandle)
	        return

	    but cDate = "tomorrow"
	        aToday = _TodayYMD()
	        pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
	        pNew = StzEngineDateAddDays(pHandle, 1)
	        @nYear = StzEngineDateYear(pNew)
	        @nMonth = StzEngineDateMonth(pNew)
	        @nDay = StzEngineDateDay(pNew)
	        StzEngineDateFree(pNew)
	        StzEngineDateFree(pHandle)
	        return
	    ok

	    if StzLeft(cDate, 3) = "in "
	        aValueUnit = ExtractValueAndUnit(StzRight(cDate, StzLen(cDate) - 3))
	        if aValueUnit != NULL
	            nValue = aValueUnit[1]
	            cUnit = aValueUnit[2]

	            aToday = _TodayYMD()

	            switch cUnit
	                on "day"
	                    pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
	                    pNew = StzEngineDateAddDays(pHandle, nValue)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "days"
	                    pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
	                    pNew = StzEngineDateAddDays(pHandle, nValue)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "week"
	                    pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
	                    pNew = StzEngineDateAddDays(pHandle, nValue * 7)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "weeks"
	                    pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
	                    pNew = StzEngineDateAddDays(pHandle, nValue * 7)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "month"
	                    aResult = _DateAddMonths(aToday[1], aToday[2], aToday[3], nValue)
	                    @nYear = aResult[1]
	                    @nMonth = aResult[2]
	                    @nDay = aResult[3]
	                on "months"
	                    aResult = _DateAddMonths(aToday[1], aToday[2], aToday[3], nValue)
	                    @nYear = aResult[1]
	                    @nMonth = aResult[2]
	                    @nDay = aResult[3]
	                on "year"
	                    aResult = _DateAddYears(aToday[1], aToday[2], aToday[3], nValue)
	                    @nYear = aResult[1]
	                    @nMonth = aResult[2]
	                    @nDay = aResult[3]
	                on "years"
	                    aResult = _DateAddYears(aToday[1], aToday[2], aToday[3], nValue)
	                    @nYear = aResult[1]
	                    @nMonth = aResult[2]
	                    @nDay = aResult[3]
	                on "decade"
	                    pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
	                    pNew = StzEngineDateAddDays(pHandle, nValue * 3650)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "decades"
	                    pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
	                    pNew = StzEngineDateAddDays(pHandle, nValue * 3650)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "century"
	                    pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
	                    pNew = StzEngineDateAddDays(pHandle, nValue * 36500)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "centuries"
	                    pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
	                    pNew = StzEngineDateAddDays(pHandle, nValue * 36500)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	            off
	            return
	        ok
	    ok

	    This.ParseStringDate(pcDate)

	    if not _IsValidDate(@nYear, @nMonth, @nDay)
	        StzRaise("Invalid date provided!")
	    ok

    def ParseStringDate(cDate)
        cDate = trim(cDate)

        aSeparators = ["/", "-", "."]
        for cSep in aSeparators
            if StzFind(cDate, cSep) > 0
                aParts = @split(cDate, cSep)
                if len(aParts) = 3
                    nA = 0 + aParts[1]
                    nB = 0 + aParts[2]
                    nC = 0 + aParts[3]

                    if nA > 100
                        @nYear = nA
                        @nMonth = nB
                        @nDay = nC
                        return
                    ok

                    if nC > 100
                        if nA > 12
                            @nDay = nA
                            @nMonth = nB
                            @nYear = nC
                        else
                            @nDay = nA
                            @nMonth = nB
                            @nYear = nC
                        ok
                        return
                    ok
                ok
            ok
        next

        if StzLen(cDate) = 8
            nA = 0 + StzLeft(cDate, 2)
            nB = 0 + StzRight(StzLeft(cDate, 4), 2)
            nC = 0 + StzRight(cDate, 4)
            if nC > 100
                @nDay = nA
                @nMonth = nB
                @nYear = nC
                return
            ok
        ok

        StzRaise("Cannot parse date string: " + cDate)

    #--- ENHANCED ARITHMETIC OPERATIONS ---#

    def AddDays(nDays)
        pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
        pNew = StzEngineDateAddDays(pHandle, nDays)
        @nYear = StzEngineDateYear(pNew)
        @nMonth = StzEngineDateMonth(pNew)
        @nDay = StzEngineDateDay(pNew)
        StzEngineDateFree(pNew)
        StzEngineDateFree(pHandle)

	    def AddDaysQ(nDays)
	        This.AddDays(nDays)
	        return This

    def AddWeeks(nWeeks)
        This.AddDays(nWeeks * 7)

	    def AddWeeksQ(nWeeks)
	        This.AddWeeks(nWeeks)
	        return This

    def AddMonths(nMonths)
        aResult = _DateAddMonths(@nYear, @nMonth, @nDay, nMonths)
        @nYear = aResult[1]
        @nMonth = aResult[2]
        @nDay = aResult[3]

	    def AddMonthsQ(nMonths)
	        This.AddMonths(nMonths)
	        return This

    def AddYears(nYears)
        aResult = _DateAddYears(@nYear, @nMonth, @nDay, nYears)
        @nYear = aResult[1]
        @nMonth = aResult[2]
        @nDay = aResult[3]

	    def AddYearsQ(nYears)
	        This.AddYears(nYears)
	        return This

    def SubtractDays(nDays)
        This.AddDays(-nDays)

	    def SubtractDaysQ(nDays)
	        This.SubtractDays(nDays)
	        return This

    def SubtractWeeks(nWeeks)
        This.AddDays(-nWeeks * 7)

	    def SubtractWeeksQ(nWeeks)
	        This.SubtractWeeks(nWeeks)
	        return This

    def SubtractMonths(nMonths)
        This.AddMonths(-nMonths)

	    def SubtractMonthsQ(nMonths)
	        This.SubtractMonths(nMonths)
	        return This

    def SubtractYears(nYears)
        This.AddYears(-nYears)

	    def SubtractYearsQ(nYears)
	        This.SubtractYears(nYears)
	        return This


    #--- SMART NAVIGATION METHODS ---#

def NextDay()
	_oCopy_ = This.Copy()
	_oCopy_.AddDays(1)
	return _oCopy_.Date()

def PreviousDay()
	_oCopy_ = This.Copy()
	_oCopy_.SubtractDays(1)
	return _oCopy_.Date()

def NextWeekday()
    nCurrentDay = This.DayOfWeek()
    _oCopy_ = This.Copy()

    if nCurrentDay < 5
        _oCopy_.AddDays(1)
    else
        _oCopy_.AddDays(8 - nCurrentDay)
    ok
    return _oCopy_.ToString()

def PreviousWeekday()
    nCurrentDay = This.DayOfWeek()
    _oCopy_ = This.Copy()

    if nCurrentDay > 1
        _oCopy_.SubtractDays(1)
    else
        _oCopy_.SubtractDays(3)
    ok
    return _oCopy_.ToString()

def NextMonday()
    nDaysToAdd = 8 - This.DayOfWeek()
    if nDaysToAdd = 8
        nDaysToAdd = 7
    ok

    _oCopy_ = This.Copy()
    _oCopy_.AddDays(nDaysToAdd)
    return _oCopy_.ToString()

def FirstDayOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, @nMonth, 1 ])
    return _oCopy_.ToString()

def LastDayOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, @nMonth, _DaysInMonth(@nYear, @nMonth) ])
    return _oCopy_.ToString()

def StartOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, @nMonth, 1 ])
    return _oCopy_.ToString()

    def StartOfMonthQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, @nMonth, 1 ])
        return _oCopy_

def EndOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, @nMonth, _DaysInMonth(@nYear, @nMonth) ])
    return _oCopy_.ToString()

    def EndOfMonthQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, @nMonth, _DaysInMonth(@nYear, @nMonth) ])
        return _oCopy_

def StartOfYear()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, 1, 1 ])
    return _oCopy_.ToString()

    def StartOfYearQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, 1, 1 ])
        return _oCopy_

def EndOfYear()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, 12, 31 ])
    return _oCopy_.ToString()

    def EndOfYearQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, 12, 31 ])
        return _oCopy_

def DayAfterMonthEnd()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, @nMonth, _DaysInMonth(@nYear, @nMonth) ])
    _oCopy_.AddDays(1)
    return _oCopy_.ToString()

    def DayAfterMonthEndQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, @nMonth, _DaysInMonth(@nYear, @nMonth) ])
        _oCopy_.AddDays(1)
        return _oCopy_

def DayBeforeMonthStart()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, @nMonth, 1 ])
    _oCopy_.SubtractDays(1)
    return _oCopy_.ToString()

    def DayBeforeMonthStartQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, @nMonth, 1 ])
        _oCopy_.SubtractDays(1)
        return _oCopy_

def DayAfterYearEnd()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, 12, 31 ])
    _oCopy_.AddDays(1)
    return _oCopy_.ToString()

    def DayAfterYearEndQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, 12, 31 ])
        _oCopy_.AddDays(1)
        return _oCopy_

def DayBeforeYearStart()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, 1, 1 ])
    _oCopy_.SubtractDays(1)
    return _oCopy_.ToString()

    def DayBeforeYearStartQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, 1, 1 ])
        _oCopy_.SubtractDays(1)
        return _oCopy_

def NextEndOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.AddMonths(1)
    _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), _oCopy_.DaysInMonthN() ])
    return _oCopy_.ToString()

    def NextEndOfMonthQ()
        _oCopy_ = This.Copy()
        _oCopy_.AddMonths(1)
        _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), _oCopy_.DaysInMonthN() ])
        return _oCopy_

def PreviousEndOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SubtractMonths(1)
    _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), _oCopy_.DaysInMonthN() ])
    return _oCopy_.ToString()

    def PreviousEndOfMonthQ()
        _oCopy_ = This.Copy()
        _oCopy_.SubtractMonths(1)
        _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), _oCopy_.DaysInMonthN() ])
        return _oCopy_

def NextStartOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.AddMonths(1)
    _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), 1 ])
    return _oCopy_.ToString()

    def NextStartOfMonthQ()
        _oCopy_ = This.Copy()
        _oCopy_.AddMonths(1)
        _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), 1 ])
        return _oCopy_

def PreviousStartOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SubtractMonths(1)
    _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), 1 ])
    return _oCopy_.ToString()

    def PreviousStartOfMonthQ()
        _oCopy_ = This.Copy()
        _oCopy_.SubtractMonths(1)
        _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), 1 ])
        return _oCopy_

def MidMonth()
    _oCopy_ = This.Copy()
    nMid = ceil(_oCopy_.DaysInMonthN() / 2)
    _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), nMid ])
    return _oCopy_.ToString()

    def MidMonthQ()
        _oCopy_ = This.Copy()
        nMid = ceil(_oCopy_.DaysInMonthN() / 2)
        _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), nMid ])
        return _oCopy_

def FirstWeekdayOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), 1 ])

    while _oCopy_.IsWeekend()
        _oCopy_.AddDays(1)
    end

    return _oCopy_.ToString()

    def FirstWeekdayOfMonthQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), 1 ])

        while _oCopy_.IsWeekend()
            _oCopy_.AddDays(1)
        end

        return _oCopy_

def LastWeekdayOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), _oCopy_.DaysInMonthN() ])

    while _oCopy_.IsWeekend()
        _oCopy_.SubtractDays(1)
    end

    return _oCopy_.ToString()

    def LastWeekdayOfMonthQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), _oCopy_.DaysInMonthN() ])

        while _oCopy_.IsWeekend()
            _oCopy_.SubtractDays(1)
        end

        return _oCopy_

    #--- ENHANCED OPERATOR OVERLOADING ---#

    def operator(op, v)

	    if op = "+"
	        if isNumber(v)
	            This.AddDays(v)
	            return This.Content()

	        but isString(v)
	            This.ParseOperation(v, "+")
	            return This.Content()
	        ok

	    but op = "-"

	        if isNumber(v)
	            This.SubtractDays(v)
	            return This.Content()

	        but isString(v)
	            This.ParseOperation(v, "-")
	            return This.Content()

	        but isObject(v) and v.IsAStzDate()
	            return abs(This.DaysTo(v))

	        else
	            StzRaise("Unsupported value! Only a stzDate object or a date in string can be provided.")
	        ok

		but op = "<"

			if (isObject(v) and v.IsAStzDate()) or
				(isString(v) and StzIsDate(v))

				return This.IsBefore(v)

			else
				StzRaise("Unsupported value! Only a stzDate onject or a date in string can be provided.")
			ok

		but op = "<="

			if (isObject(v) and v.IsAStzDate()) or
				(isString(v) and StzIsDate(v))

				return This.IsBefore(v) or This.IsEqualTo(v)

			else
				StzRaise("Unsupported value! Only a stzDate onject or a date in string can be provided.")
			ok

		but op = ">"
			if (isObject(v) and v.IsAStzDate()) or
				(isString(v) and StzIsDate(v))

				return This.IsAfter(v)

			else
				StzRaise("Unsupported value! Only a stzDate onject or a date in string can be provided.")
			ok

		but op = ">="
			if (isObject(v) and v.IsAStzDate()) or
				(isString(v) and StzIsDate(v))

				return This.IsAfter(v) or This.IsEqualTo(v)

			else
				StzRaise("Unsupported value! Only a stzDate onject or a date in string can be provided.")
			ok

		but op = "="
			if (isObject(v) and v.IsAStzDate()) or
				(isString(v) and StzIsDate(v))

				return This.IsEqualTo(v)
			else
				StzRaise("Unsupported value! Only a stzDate onject or a date in string can be provided.")
			ok
        ok


	def ParseOperation(cOperation, cOperator)
	    aValueUnit = ExtractValueAndUnit(cOperation)

	    if aValueUnit = NULL
	        StzRaise("Invalid operation format. Use 'n days/weeks/months/years'")
	    ok

	    nValue = aValueUnit[1]
	    cUnit = aValueUnit[2]

	    if cOperator = "-"
	        nValue = -nValue
	    ok

	    switch cUnit
	        on "day"
	            This.AddDays(nValue)

	        on "days"
	            This.AddDays(nValue)

	        on "week"
	            This.AddWeeks(nValue)

	        on "weeks"
	            This.AddWeeks(nValue)

	        on "month"
	            This.AddMonths(nValue)

	        on "months"
	            This.AddMonths(nValue)

	        on "year"
	            This.AddYears(nValue)

	        on "years"
	            This.AddYears(nValue)

	        other
	            StzRaise("Invalid unit! Use 'days', 'weeks', 'months', or 'years'.")
	    off

    #--- COMPARISON METHODS ---#

    def DaysTo(oOtherDate)

	if isList(oOtherDate) and len(oOtherDate) = 3
		if IsListOfNumbers(oOtherDate)
			cOtherDate = '' + oOtherDate[1] + "-" + oOtherDate[2] + "-" + oOtherDate[3]
			oOtherDate = cOtherDate

		but IsHashList(oOtherDate) and HasKeys(oOtherDate, [ :Year, :Month, :Day ])
			cOtherDate = '' + oOtherDate[:Year] + "-" + oOtherDate[:Month] + "-" + oOtherDate[:Day]
			oOtherDate = cOtherDate
		ok
	ok

        if isString(oOtherDate)
            oTempDate = new stzDate(oOtherDate)
	    oOtherDate = oTempDate
        ok

        if not isObject(oOtherDate) or not ring_classname(oOtherDate) = "stzdate"
            StzRaise("Parameter must be a stzDate object or date string")
        ok

        pHandle1 = StzEngineDateNew(@nYear, @nMonth, @nDay)
        pHandle2 = StzEngineDateNew(oOtherDate.Year(), oOtherDate.MonthN(), oOtherDate.DayN())
        nResult = StzEngineDateDiffDays(pHandle1, pHandle2)
        StzEngineDateFree(pHandle1)
        StzEngineDateFree(pHandle2)
	return nResult

	def DaysToN(oOtherDate)
		return This.DaysTo(oOtherDate)

	def DaysToDate(oOtherDate)
		return This.DaysTo(oOtherDate)

	def DaysToDateN(oOtherDate)
		return This.DaysTo(oOtherDate)

    def WeeksTo(oOtherDate)
        return floor(This.DaysTo(oOtherDate) / 7)

	def WeeksToN(oOtherDate)
		return this.WeeksTo(oOtherDate)

	def WeeksToDate(oOtherDate)
		return this.WeeksTo(oOtherDate)

	def WeeksToDateN(oOtherDate)
		return this.WeeksTo(oOtherDate)

    def MonthsTo(oOtherDate)
        if isList(oOtherDate) and len(oOtherDate) = 3
	        if IsListOfNumbers(oOtherDate)
	            oOtherDate = new stzDate('' + oOtherDate[1] + "-" + oOtherDate[2] + "-" + oOtherDate[3])
	        but IsHashList(oOtherDate) and HasKeys(oOtherDate, [ :Year, :Month, :Day ])
	            oOtherDate = new stzDate('' + oOtherDate[:Year] + "-" + oOtherDate[:Month] + "-" + oOtherDate[:Day])
	        ok
        ok

        if isString(oOtherDate)
            oOtherDate = new stzDate(oOtherDate)
        ok

        nYears = oOtherDate.Year() - This.Year()
        nMonths = oOtherDate.MonthN() - This.MonthN()

        return (nYears * 12) + nMonths

	def MonthsToN(oOtherDate)
		return This.MonthsTo(oOtherDate)

	def MonthsToDate(oOtherDate)
		return This.MonthsTo(oOtherDate)

	def MonthsToDateN(oOtherDate)
		return This.MonthsTo(oOtherDate)

    def YearsTo(oOtherDate)
        if isList(oOtherDate) and len(oOtherDate) = 3
	        if IsListOfNumbers(oOtherDate)
	            oOtherDate = new stzDate('' + oOtherDate[1] + "-" + oOtherDate[2] + "-" + oOtherDate[3])
	        but IsHashList(oOtherDate) and HasKeys(oOtherDate, [ :Year, :Month, :Day ])
	            oOtherDate = new stzDate('' + oOtherDate[:Year] + "-" + oOtherDate[:Month] + "-" + oOtherDate[:Day])
	        ok
        ok

        if isString(oOtherDate)
            oOtherDate = new stzDate(oOtherDate)
        ok

        return oOtherDate.Year() - This.Year()

	def YearsToN(oOtherDate)
		return This.YearsTo(oOtherDate)

	def YearsToDate(oOtherDate)
		return This.YearsTo(oOtherDate)

	def YearsToDateN(oOtherDate)
		return This.YearsTo(oOtherDate)


    def IsBefore(oOtherDate)
        return This.DaysTo(oOtherDate) > 0

    def IsAfter(oOtherDate)
        return This.DaysTo(oOtherDate) < 0

    def IsEqualTo(oOtherDate)
        return This.DaysTo(oOtherDate) = 0

		def IsEqual(oOtherDate)
			return This.DaysTo(oOtherDate) = 0

    def IsSameWeek(oOtherDate)
	    if isList(oOtherDate) and len(oOtherDate) = 3
	        if IsListOfNumbers(oOtherDate)
	            oOtherDate = new stzDate('' + oOtherDate[1] + "-" + oOtherDate[2] + "-" + oOtherDate[3])
	        but IsHashList(oOtherDate) and HasKeys(oOtherDate, [ :Year, :Month, :Day ])
	            oOtherDate = new stzDate('' + oOtherDate[:Year] + "-" + oOtherDate[:Month] + "-" + oOtherDate[:Day])
	        ok
	    ok

        if isString(oOtherDate)
            oOtherDate = new stzDate(oOtherDate)
        ok
        return This.WeekNumber() = oOtherDate.WeekNumber() and This.YearN() = oOtherDate.YearN()

    def IsSameMonth(oOtherDate)
	    if isList(oOtherDate) and len(oOtherDate) = 3
	        if IsListOfNumbers(oOtherDate)
	            oOtherDate = new stzDate('' + oOtherDate[1] + "-" + oOtherDate[2] + "-" + oOtherDate[3])
	        but IsHashList(oOtherDate) and HasKeys(oOtherDate, [ :Year, :Month, :Day ])
	            oOtherDate = new stzDate('' + oOtherDate[:Year] + "-" + oOtherDate[:Month] + "-" + oOtherDate[:Day])
	        ok
	    ok

        if isString(oOtherDate)
            oOtherDate = new stzDate(oOtherDate)
        ok
        return This.MonthN() = oOtherDate.MonthN() and This.YearN() = oOtherDate.YearN()

    def IsSameYear(oOtherDate)
	    if isList(oOtherDate) and len(oOtherDate) = 3
	        if IsListOfNumbers(oOtherDate)
	            oOtherDate = new stzDate('' + oOtherDate[1] + "-" + oOtherDate[2] + "-" + oOtherDate[3])
	        but IsHashList(oOtherDate) and HasKeys(oOtherDate, [ :Year, :Month, :Day ])
	            oOtherDate = new stzDate('' + oOtherDate[:Year] + "-" + oOtherDate[:Month] + "-" + oOtherDate[:Day])
	        ok
	    ok

        if isString(oOtherDate)
            oOtherDate = new stzDate(oOtherDate)
        ok
        return This.YearN() = oOtherDate.YearN()

    #--- UTILITY CHECKS ---#

    def IsWeekend()
        nDay = This.DayOfWeek()
        return (nDay = 6 or nDay = 7)

    def IsWeekday()
        return not This.IsWeekend()

    def IsToday()
        aToday = _TodayYMD()
        if @nYear = aToday[1] and @nMonth = aToday[2] and @nDay = aToday[3]
			return 1
		else
			return 0
		ok

    def IsYesterday()
        aToday = _TodayYMD()
        pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
        pYesterday = StzEngineDateAddDays(pHandle, -1)
        nY = StzEngineDateYear(pYesterday)
        nM = StzEngineDateMonth(pYesterday)
        nD = StzEngineDateDay(pYesterday)
        StzEngineDateFree(pYesterday)
        StzEngineDateFree(pHandle)
        return @nYear = nY and @nMonth = nM and @nDay = nD

    def IsTomorrow()
        aToday = _TodayYMD()
        pHandle = StzEngineDateNew(aToday[1], aToday[2], aToday[3])
        pTomorrow = StzEngineDateAddDays(pHandle, 1)
        nY = StzEngineDateYear(pTomorrow)
        nM = StzEngineDateMonth(pTomorrow)
        nD = StzEngineDateDay(pTomorrow)
        StzEngineDateFree(pTomorrow)
        StzEngineDateFree(pHandle)
        return @nYear = nY and @nMonth = nM and @nDay = nD

    def Age()
        _oToday_ = new stzDate("")
        nYears = This.YearsTo(_oToday_)
        if nYears < 0
            nYears = -nYears
        ok
        return nYears

    #--- ENHANCED GETTERS ---#

    def Year()
        return @nYear

    	def YearN()
        	return @nYear

    def Month()
        return GetMonthName(@nMonth)

	def MonthName()
		return GetMonthName(@nMonth)

    def MonthN()
        return @nMonth

	    def MonthNumber()
	        return @nMonth

    def MonthNumberInString()
        return _PadLeft("" + @nMonth, 2, "0")

    def MonthInLanguage(cLanguage)
        return GetMonthNameXT(@nMonth, cLanguage)

    def MonthIn(cLanguage)
        return This.MonthInLanguage(cLanguage)

    def MonthShort()
        cMonth = This.Month()
        return StzLeft(cMonth, 3)

    def Day()
        return GetDayName(This.DayOfWeek())

	def DayName()
		return This.Day()

    def DayN()
        return @nDay

   	 	def DayNumber()
        	return @nDay

    def DayInLanguage(cLanguage)
        return GetDayNameXT(This.DayOfWeek(), cLanguage)

    def DayIn(cLanguage)
        return DayInLanguage(cLanguage)

    def DayShort()
        cDay = This.Day()
        return StzLeft(cDay, 3)

    def DayOfWeek()
        pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
        nResult = StzEngineDateDayOfWeek(pHandle)
        StzEngineDateFree(pHandle)
        return nResult

    	def DayOfWeekN()
        	return This.DayOfWeek()

    def DayOfYear()
        pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
        nResult = StzEngineDateDayOfYear(pHandle)
        StzEngineDateFree(pHandle)
        return nResult

    	def DayOfYearN()
       		 return This.DayOfYear()

    def WeekNumber()
        pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
        nDayOfYear = StzEngineDateDayOfYear(pHandle)
        StzEngineDateFree(pHandle)

        pJan1 = StzEngineDateNew(@nYear, 1, 1)
        nJan1DayOfWeek = StzEngineDateDayOfWeek(pJan1)
        StzEngineDateFree(pJan1)

        nWeek = floor((nDayOfYear + nJan1DayOfWeek - 2) / 7) + 1

        if nWeek = 0
            nWeek = 52
            pDec31 = StzEngineDateNew(@nYear-1, 12, 31)
            nDec31Dow = StzEngineDateDayOfWeek(pDec31)
            StzEngineDateFree(pDec31)
            if nDec31Dow = 4
                nWeek = 53
            ok
        ok

        return nWeek

    def DaysInMonth()
        return _DaysInMonth(@nYear, @nMonth)

    	def DaysInMonthN()
        	return _DaysInMonth(@nYear, @nMonth)

    def DaysInYear()
        if _IsLeapYear(@nYear) return 366 else return 365 ok

    	def DaysInYearN()
        	if _IsLeapYear(@nYear) return 366 else return 365 ok

    def IsLeapYear()
        return _IsLeapYear(@nYear)

		def ISLeap()
			return _IsLeapYear(@nYear)

    #--- HUMAN-READABLE FORMATTING ---#

    def ToHuman()
	    oToday = new stzDate("")
	    nDays = This.DaysTo(oToday)
	    nDays = -nDays

	    if nDays = 0
	        return "today"

	    but nDays = 1
	        return "tomorrow"

	    but nDays = -1
	        return "yesterday"

	    but nDays > 0 and nDays <= 7
	        return "In " + nDays + " day" + Iff(nDays=1, "", "s")

	    but nDays < 0 and nDays >= -7
	        return '' + (-nDays) + " day" + Iff(nDays=-1, "", "s") + " ago"

	    else
	        nDay = This.DayN()
	        cDaySuffix = DayOrdinalSuffix(nDay)
	        cHuman = This.Day() + ", " + This.Month() + " " + nDay + cDaySuffix + ", " + This.Year()
	        return cHuman
	    ok


    def ToRelative()
	    oToday = new stzDate("")
	    nDays = This.DaysTo(oToday)
	    nDays = -nDays

	    if nDays = 0
	        return "today"

	    but nDays = 1
	        return "tomorrow"

	    but nDays = -1
	        return "yesterday"

	    but nDays > 1 and nDays <= 7
	        return "in " + nDays + " days"

	    but nDays > 7 and nDays <= 14
	        return "in 1 week"

	    but nDays > 14 and nDays <= 30
	        nWeeks = floor(nDays / 7)
	        return "in " + nWeeks + " weeks"

	    but nDays < -1 and nDays >= -7
	        return '' + (-nDays) + " days ago"

	    but nDays < -7 and nDays >= -14
	        return "1 week ago"

	    but nDays < -14 and nDays >= -30
	        nWeeks = floor((-nDays) / 7)
	        return '' + nWeeks + " weeks ago"

	    else
	        return This.ToString()
	    ok


    def ToString()
        return This.ToStringXT("")

		def Content()
			return This.ToString()

		def Date()
			return This.ToString()

    def ToStringXT(cFormat)
        if cFormat = ""
            cFormat = $cDefaultDateFormat
        ok

        cLowerFormat = StzLower(cFormat)
        for aFormat in $aDateFormats
            if StzLower(aFormat[1]) = cLowerFormat
                cFormat = aFormat[2]
                exit
            ok
        next

        return _DateFormatString(@nYear, @nMonth, @nDay, cFormat)

    def ToISO8601()
        return This.ToStringXT("yyyy-MM-dd")

    def ToEuropean()
        return This.ToStringXT("dd/MM/yyyy")

    def ToAmerican()
        return This.ToStringXT("MM/dd/yyyy")

    def ToShort()
        return This.DayShort() + " " + This.DayN() + " " + This.MonthShort()

    def ToLong()
        return This.Day() + ", " + This.Month() + " " + This.DayN() + ", " + This.Year()

    #--- JULIAN DAY METHODS ---#

    def ToJulianDay()
        nA = floor((14 - @nMonth) / 12)
        nY = @nYear + 4800 - nA
        nM = @nMonth + 12 * nA - 3
        return @nDay + floor((153 * nM + 2) / 5) + 365 * nY + floor(nY / 4) - floor(nY / 100) + floor(nY / 400) - 32045

    def FromJulianDay(nJulianDay)
        nA = nJulianDay + 32044
        nB = floor((4 * nA + 3) / 146097)
        nC = nA - floor(146097 * nB / 4)
        nD = floor((4 * nC + 3) / 1461)
        nE = nC - floor(1461 * nD / 4)
        nM = floor((5 * nE + 2) / 153)
        @nDay = nE - floor((153 * nM + 2) / 5) + 1
        @nMonth = nM + 3 - 12 * floor(nM / 10)
        @nYear = 100 * nB + nD - 4800 + floor(nM / 10)

	    def FromJulianDayQ(nJulianDay)
	        This.FromJulianDay(nJulianDay)
	        return This

    #--- BATCH OPERATIONS ---#

    def IsBetween(oStartDate, oEndDate)
	if CheckParams()
		if isList(oEndDate) and IsAndNamedParamList(oEndDate)
			oEndDate = oEndDate[2]
		ok
	ok

        if isList(oStartDate) and len(oStartDate) = 3
	        if IsListOfNumbers(oStartDate)
	            oStartDate = new stzDate('' + oStartDate[1] + "-" + oStartDate[2] + "-" + oStartDate[3])
	        but IsHashList(oStartDate) and HasKeys(oStartDate, [ :Year, :Month, :Day ])
	            oStartDate = new stzDate('' + oStartDate[:Year] + "-" + oStartDate[:Month] + "-" + oStartDate[:Day])
	        ok
        ok

        if isList(oEndDate) and len(oEndDate) = 3
	        if IsListOfNumbers(oEndDate)
	            oEndDate = new stzDate('' + oEndDate[1] + "-" + oEndDate[2] + "-" + oEndDate[3])
	        but IsHashList(oEndDate) and HasKeys(oEndDate, [ :Year, :Month, :Day ])
	            oEndDate = new stzDate('' + oEndDate[:Year] + "-" + oEndDate[:Month] + "-" + oEndDate[:Day])
	        ok
        ok

        if isString(oStartDate)
            oStartDate = new stzDate(oStartDate)
        ok
        if isString(oEndDate)
            oEndDate = new stzDate(oEndDate)
        ok

        return This.IsAfter(oStartDate) and This.IsBefore(oEndDate)

    def Copy()
        oCopy = new stzDate([ @nYear, @nMonth, @nDay ])
        return oCopy

    #--- UTILITY METHODS ---#

    def SetComponents(aDate)
        if isList(aDate) and len(aDate) = 3
            @nYear = aDate[1]
            @nMonth = aDate[2]
            @nDay = aDate[3]
        ok

    def SetComponentsQ(aDate)
        This.SetComponents(aDate)
        return This

    def Components()
        return [ @nYear, @nMonth, @nDay ]

    def IsValid()
        if _IsValidDate(@nYear, @nMonth, @nDay)
            return 1
        else
            return 0
        ok

    def IsAStzDate()
        return TRUE

   func ExtractValueAndUnit(cExpression)
	    cExpression = StzLower(trim(cExpression))
	    acWords = @split(cExpression, " ")
	    if len(acWords) < 2

	        return NULL
	    ok

	    nValue = 0 + acWords[1]
	    cUnit = acWords[2]

	    return [ nValue, cUnit ]
