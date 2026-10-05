
#TODO Make a bridge with stzLocale to let the stzDate class be locale-sensitive

# Multi-language day names
$aDayNames = [
    [ :English, [ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" ] ],
    [ :French, [ "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche" ] ],
    [ :Arabic, [ "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت", "الأحد" ] ]
]

# Multi-language month names
$aMonthNames = [
    [ :English, [ "January", "February", "March", "April", "May", "June", 
                 "July", "August", "September", "October", "November", "December" ] ],
    [ :French, [ "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
                "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre" ] ],
    [ :Arabic, [ "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
                "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر" ] ]
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

# Freezable wall-clock globals (see StzFreezeClock for full notes).
# Must be initialised at module top-level so every later func sees them
# as legitimate globals rather than uninitialised locals.
$cStzFrozenDate = ""
$cStzFrozenTime = ""

func _DaysInMonth(_nYear_, _nMonth_)
    _aMonthDays_ = [31,28,31,30,31,30,31,31,30,31,30,31]
    if _nMonth_ = 2 and _IsLeapYear(_nYear_) return 29 ok
    return _aMonthDays_[_nMonth_]

func _IsLeapYear(_nYear_)
    if _nYear_ % 400 = 0 return 1 ok
    if _nYear_ % 100 = 0 return 0 ok
    if _nYear_ % 4 = 0 return 1 ok
    return 0

func _DateAddMonths(_nYear_, _nMonth_, _nDay_, _nMonths_)
    _nMonth_ += _nMonths_
    while _nMonth_ > 12
        _nMonth_ -= 12
        _nYear_++
    end
    while _nMonth_ < 1
        _nMonth_ += 12
        _nYear_--
    end
    _nMaxDay_ = _DaysInMonth(_nYear_, _nMonth_)
    if _nDay_ > _nMaxDay_ _nDay_ = _nMaxDay_ ok
    return [_nYear_, _nMonth_, _nDay_]

func _DateAddYears(_nYear_, _nMonth_, _nDay_, _nYears_)
    _nYear_ += _nYears_
    _nMaxDay_ = _DaysInMonth(_nYear_, _nMonth_)
    if _nDay_ > _nMaxDay_ _nDay_ = _nMaxDay_ ok
    return [_nYear_, _nMonth_, _nDay_]

func _DateFormatString(_nYear_, _nMonth_, _nDay_, _cFormat_)
    pHandle = StzEngineDateNew(_nYear_, _nMonth_, _nDay_)
    _cDayName_ = StzEngineDateDayName(pHandle)
    _cMonthName_ = StzEngineDateMonthName(pHandle)
    StzEngineDateFree(pHandle)

    # Replace tokens by descending length into ASCII-safe placeholders
    # (\x01..\x07) so a freshly-substituted name like "Wednesday" (which
    # contains "d") doesn't get clobbered by the single-letter "d" pass.

    _cResult_ = _cFormat_
    _cResult_ = StzReplace(_cResult_, "dddd", char(1))
    _cResult_ = StzReplace(_cResult_, "ddd",  char(2))
    _cResult_ = StzReplace(_cResult_, "dd",   char(3))
    _cResult_ = StzReplace(_cResult_, "d",    char(4))
    _cResult_ = StzReplace(_cResult_, "MMMM", char(5))
    _cResult_ = StzReplace(_cResult_, "MMM",  char(6))
    _cResult_ = StzReplace(_cResult_, "MM",   char(7))
    _cResult_ = StzReplace(_cResult_, "M",    char(8))
    _cResult_ = StzReplace(_cResult_, "yyyy", "" + _nYear_)
    _nYY_ = _nYear_ % 100
    _cResult_ = StzReplace(_cResult_, "yy",   _PadLeft("" + _nYY_, 2, "0"))

    _cResult_ = StzReplace(_cResult_, char(1), _cDayName_)
    _cResult_ = StzReplace(_cResult_, char(2), StzLeft(_cDayName_, 3))
    _cResult_ = StzReplace(_cResult_, char(3), _PadLeft("" + _nDay_, 2, "0"))
    _cResult_ = StzReplace(_cResult_, char(4), "" + _nDay_)
    _cResult_ = StzReplace(_cResult_, char(5), _cMonthName_)
    _cResult_ = StzReplace(_cResult_, char(6), StzLeft(_cMonthName_, 3))
    _cResult_ = StzReplace(_cResult_, char(7), _PadLeft("" + _nMonth_, 2, "0"))
    _cResult_ = StzReplace(_cResult_, char(8), "" + _nMonth_)
    return _cResult_

func _PadLeft(_cStr_, nWidth, cPadChar)
    while len(_cStr_) < nWidth
        _cStr_ = cPadChar + _cStr_
    end
    return _cStr_

func _TodayYMD()
    # Honor the freezable wall-clock when set (see StzFreezeClock).
    # Engine path is bypassed in that mode so snapshot tests stay
    # deterministic across the entire stzDate surface (init(""),
    # AddDays, Navigation methods, Age, etc., all of which route
    # here rather than through StzSysDate).
    if $cStzFrozenDate != ""
        _acTymdParts_ = split($cStzFrozenDate, "/")
        if len(_acTymdParts_) = 3
            return [ 0+ _acTymdParts_[3], 0+ _acTymdParts_[2], 0+ _acTymdParts_[1] ]
        ok
    ok

    pHandle = StzEngineDateToday()
    _nY_ = StzEngineDateYear(pHandle)
    _nM_ = StzEngineDateMonth(pHandle)
    _nD_ = StzEngineDateDay(pHandle)
    StzEngineDateFree(pHandle)
    return [_nY_, _nM_, _nD_]

func _IsValidDate(_nYear_, _nMonth_, _nDay_)
    if _nMonth_ < 1 or _nMonth_ > 12 return 0 ok
    if _nDay_ < 1 or _nDay_ > _DaysInMonth(_nYear_, _nMonth_) return 0 ok
    return 1

func StzTimeStamp()
	return StzSysDate() + " " + StzSysTime()

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
    _oDate_ = StzDateQ("")
    _nDaysToSubtract_ = _oDate_.DayOfWeekN() - 1
    return _oDate_.SubtractDaysQ(_nDaysToSubtract_).Content()

	func StartOfWeek()
		return StzStartOfWeek()

func StzEndOfWeek()
    _oDate_ = StzStartOfWeek()
    return _oDate_.AddDaysQ(6).Content()

	func EndOfWeek()
		return StzEndOfWeek()

func StzStartOfMonth()
    _oDate_ = StzDateQ("")
    return StzDateQ("01/" + _oDate_.MonthNumberInString() + "/" + _oDate_.Year()).Content()

	func StartOfMonth()
		return StzStartOfMonth()

func StzEndOfMonth()
    _oDate_ = StzDateQ("")
    _nDays_ = _oDate_.DaysInMonthN()
    return StzDateQ('' + _nDays_ + "/" + _oDate_.MonthNumberInString() + "/" + _oDate_.Year()).Content()

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

func StzGetDayNameXT(nDayOfWeek, _cLanguage_)
    if _cLanguage_ = ""
        _cLanguage_ = $cCurrentLanguage
    ok

    _nDayNames2Len_ = len($aDayNames)
    for _iLoopDayNames2_ = 1 to _nDayNames2Len_
    	_aLang_ = $aDayNames[_iLoopDayNames2_]
        if _aLang_[1] = _cLanguage_
            return _aLang_[2][nDayOfWeek]
        ok
    next

    _nDayNames1Len_ = len($aDayNames)
    for _iLoopDayNames1_ = 1 to _nDayNames1Len_
    	_aLang_ = $aDayNames[_iLoopDayNames1_]
        if _aLang_[1] = :English
            return _aLang_[2][nDayOfWeek]
        ok
    next

	func GetDayNameXT(nDayOfWeek, _cLanguage_)
		return StzGetDayNameXT(nDayOfWeek, _cLanguage_)

	func StzGetDayNameInLanguage(nDayOfWeek, _cLanguage_)
		return StzGetDayNameXT(nDayOfWeek, _cLanguage_)

	func GetDayNameInLanguage(nDayOfWeek, _cLanguage_)
		return StzGetDayNameXT(nDayOfWeek, _cLanguage_)

func StzGetMonthName(_nMonth_)
	return StzGetMonthNameInLanguage(_nMonth_, :English)

	func GetMonthName(_nMonth_)
		return StzGetMonthName(_nMonth_)

func StzGetMonthNameInLanguage(_nMonth_, _cLanguage_)
    if _cLanguage_ = ""
        _cLanguage_ = $cCurrentLanguage
    ok

    _nMonthNames2Len_ = len($aMonthNames)
    for _iLoopMonthNames2_ = 1 to _nMonthNames2Len_
    	_aLang_ = $aMonthNames[_iLoopMonthNames2_]
        if _aLang_[1] = _cLanguage_
            return _aLang_[2][_nMonth_]
        ok
    next

    _nMonthNames1Len_ = len($aMonthNames)
    for _iLoopMonthNames1_ = 1 to _nMonthNames1Len_
    	_aLang_ = $aMonthNames[_iLoopMonthNames1_]
        if _aLang_[1] = :English
            return _aLang_[2][_nMonth_]
        ok
    next

	func GetMonthNameInLanguage(_nMonth_, _cLanguage_)
		return StzGetMonthNameInLanguage(_nMonth_, _cLanguage_)

	func StzGetMonthNameXT(_nMonth_, _cLanguage_)
		return StzGetMonthNameInLanguage(_nMonth_, _cLanguage_)

	func GetMonthNameXT(_nMonth_, _cLanguage_)
		return StzGetMonthNameInLanguage(_nMonth_, _cLanguage_)

# --- Freezable wall-clock --------------------------------------------------
# A small global lets tests and demos pin the wall clock to a known instant
# so snapshot assertions (Today(), Now(), Date(), Time()) stay stable across
# runs. The freeze ONLY affects code routed through the Stz wrappers below;
# the underlying Ring date()/time() builtins are never touched.
#
# Format is the canonical "YYYY-MM-DD HH:MM:SS". Either half may be empty
# (e.g. just a date) in which case the other half falls back to live system
# time. StzUnfreezeClock() restores live behaviour.
#
# Tests use it via the # @clock YYYY-MM-DD HH:MM:SS pragma honoured by the
# modular test runner.

func StzFreezeClock(_cTimestamp_)
	# Accept "YYYY-MM-DD HH:MM:SS", "YYYY-MM-DD", or "HH:MM:SS".
	_cTimestamp_ = trim(_cTimestamp_)
	if _cTimestamp_ = ""
		StzUnfreezeClock()
		return
	ok
	_acStzFcParts_ = split(_cTimestamp_, " ")
	if len(_acStzFcParts_) >= 1 and StzLen(_acStzFcParts_[1]) >= 8 and StzMid(_acStzFcParts_[1], 5, 1) = "-"
		# Date half -- convert from ISO YYYY-MM-DD to Ring's DD/MM/YYYY.
		_cStzFcY_ = StzMid(_acStzFcParts_[1], 1, 4)
		_cStzFcM_ = StzMid(_acStzFcParts_[1], 6, 2)
		_cStzFcD_ = StzMid(_acStzFcParts_[1], 9, 2)
		$cStzFrozenDate = _cStzFcD_ + "/" + _cStzFcM_ + "/" + _cStzFcY_
	but len(_acStzFcParts_) >= 1 and StzMid(_acStzFcParts_[1], 3, 1) = ":"
		# First half is actually a time
		$cStzFrozenTime = _acStzFcParts_[1]
		return
	ok
	if len(_acStzFcParts_) >= 2
		$cStzFrozenTime = _acStzFcParts_[2]
	ok

	func FreezeClock(_cTimestamp_)
		StzFreezeClock(_cTimestamp_)

func StzUnfreezeClock()
	$cStzFrozenDate = ""
	$cStzFrozenTime = ""

	func UnfreezeClock()
		StzUnfreezeClock()

func StzClockIsFrozen()
	return $cStzFrozenDate != "" or $cStzFrozenTime != ""

func StzSysDate()
	if $cStzFrozenDate != ""
		return $cStzFrozenDate
	ok
	return date()

	func SysDate()
		return StzSysDate()

	func StzDateSys()
		return StzSysDate()

	func DateSys()
		return StzSysDate()

func StzSysTime()
	if $cStzFrozenTime != ""
		return $cStzFrozenTime
	ok
	return time()

	func SysTime()
		return StzSysTime()

func StzAddDays(_cDate_, n)
	return addDays(_cDate_, n)

	func ring_addDays(_cDate_, n)
		return StzAddDays(_cDate_, n)

func StzDateQ(pDate)
    return new stzDate(pDate)

# Bare ToDate helper: just builds a stzDate from any accepted form
# and returns its canonical content. Symmetric with ToString /
# ToInt / etc. helpers used across the narrative tests.
func ToDate(pDate)
    return StzDateQ(pDate).Content()

func StzNow()
	return StzSysDate() + " " + StzSysTime()

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
	return Rx.MatchFirst(str)

	func IsDate(str)
		return StzIsDate(str)

	func StzIsValidDate(str)
		return StzIsDate(str)

	func IsValidDate(str)
		return StzIsDate(str)

func StzDayOrdinalSuffix(_nDay_)
    if _nDay_ % 10 = 1 and _nDay_ != 11
        return "st"
    but _nDay_ % 10 = 2 and _nDay_ != 12
        return "nd"
    but _nDay_ % 10 = 3 and _nDay_ != 13
        return "rd"
    else
        return "th"
    ok

	func DayOrdinalSuffix(_nDay_)
		return StzDayOrdinalSuffix(_nDay_)

# Holds one calendar date (year, month, day) with no time of day, moves it by days, months or years, compares it and writes it in several formats.
#
# A stzDate is three numbers. Build it from a text (2026-03-15, 15/03/2026, 15.03.2026, 15032026,
# today, in 3 days), from a list [ 2026, 3, 15 ], from a hash with :Year, :Month and :Day, or from
# an empty text for today. A text with a 4-digit first part is read year-first, any other text day-
# first, so 03/15/2026 raises. The Add and Subtract methods move the object itself and return
# nothing (the Q forms answer the object so calls chain); the Next, Previous, Start and End methods
# answer a text in dd/MM/yyyy and leave the object alone (their Q forms answer a copy). Measure with
# DaysTo, WeeksTo, MonthsTo and YearsTo, compare with IsBefore, IsAfter, IsEqualTo and IsBetween,
# and write it with ToString (dd/MM/yyyy), ToISO8601, ToAmerican, ToLong or ToStringXT with a format
# such as yyyy-MM-dd. Dates before 1970 work, because the engine counts civil days and not Unix
# seconds. Today follows StzFreezeClock, so a test can pin it. Known gaps today, each carried as a
# warning on its method: MonthsTo, YearsTo, IsSameWeek, IsSameMonth, IsSameYear and IsBetween raise
# for anything but a stzDate object; DaysTo and the Is comparisons overwrite a list or hash variable
# of the caller; PreviousWeekday answers a Saturday from a Sunday; Age counts year numbers only; a
# language given with a capital (French) falls back to English; a list or hash given to the
# constructor is not validated.
#
#   receiver   o1 = new stzDate("2026-03-15")
#   example    ? o1.AddDaysQ(3).ToISO8601()
#              #--> 2026-03-18
#   see        stzDateTime, stzTime, stzCalendar
class stzDate from stzObject
    @nYear
    @nMonth
    @nDay

    	# Builds the date from a date text, a [ year, month, day ] list, a hash with :Year, :Month and :Day, or today when the text is empty.
    	#
    	#   pcDate     a date text such as 2026-03-15 or 15/03/2026, the words today, yesterday or
    	#              tomorrow, a phrase such as in 3 days, a list [ 2026, 3, 15 ], or a hash [
    	#              :Year = 2026, :Month = 3, :Day = 15 ]
    	#   returns    nothing; the object is built
    	#   note       text with 4 digits first is read year-first (yyyy-MM-dd, yyyy/M/d), otherwise
    	#              day-first (dd/MM/yyyy, dd.MM.yyyy, ddMMyyyy); an empty text is today and
    	#              follows StzFreezeClock; dates before 1970 are fine here, unlike stzDateTime
    	#   warning    a text is checked (2026-02-30 raises Invalid date provided!) but a list or
    	#              hash is not (13 as month is stored and IsValid answers FALSE); text with the
    	#              month first such as 03/15/2026 is read day-first and raises; a number, or a
    	#              list that is not 3 numbers, raises Can't create the stzDate object; a two-
    	#              digit year (15-03-26) raises R41; a phrase with a unit other than day, week,
    	#              month, year, decade or century leaves the date empty without an error
    	#   see        SetDate, ParseStringDate
    	def init(pcDate)
		This.SetDate(pcDate)

	# Replaces the date by the one given in any form the constructor accepts, leaving the other fields of the object alone.
	#
	#   pcDate     a date text, a phrase such as tomorrow or in 2 weeks, a list [ y, m, d ] or a
	#              hash with :Year, :Month and :Day
	#   returns    nothing; the object changes in place
	#   note       the same forms and rules as init
	#   warning    a text with an impossible day (2026-02-30) raises Invalid date provided! only
	#              AFTER the fields were overwritten, so the object keeps the invalid date; a phrase
	#              with an unknown unit changes nothing
	#   see        init, SetComponents
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

	    _cDate_ = StzLower(trim(pcDate))
	    _nLenDate_ = len(_cDate_)


	    if _cDate_ = ''
	        _aToday_ = _TodayYMD()
	        @nYear = _aToday_[1]
	        @nMonth = _aToday_[2]
	        @nDay = _aToday_[3]
	        return

	    but _cDate_ = "today"
	        _aToday_ = _TodayYMD()
	        @nYear = _aToday_[1]
	        @nMonth = _aToday_[2]
	        @nDay = _aToday_[3]
	        return

	    but _cDate_ = "yesterday"
	        _aToday_ = _TodayYMD()
	        pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
	        pNew = StzEngineDateAddDays(pHandle, -1)
	        @nYear = StzEngineDateYear(pNew)
	        @nMonth = StzEngineDateMonth(pNew)
	        @nDay = StzEngineDateDay(pNew)
	        StzEngineDateFree(pNew)
	        StzEngineDateFree(pHandle)
	        return

	    but _cDate_ = "tomorrow"
	        _aToday_ = _TodayYMD()
	        pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
	        pNew = StzEngineDateAddDays(pHandle, 1)
	        @nYear = StzEngineDateYear(pNew)
	        @nMonth = StzEngineDateMonth(pNew)
	        @nDay = StzEngineDateDay(pNew)
	        StzEngineDateFree(pNew)
	        StzEngineDateFree(pHandle)
	        return
	    ok

	    if StzLeft(_cDate_, 3) = "in "
	        _aValueUnit_ = ExtractValueAndUnit(StzRight(_cDate_, StzLen(_cDate_) - 3))
	        if _aValueUnit_ != ""
	            _nValue_ = _aValueUnit_[1]
	            _cUnit_ = _aValueUnit_[2]

	            _aToday_ = _TodayYMD()

	            switch _cUnit_
	                on "day"
	                    pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
	                    pNew = StzEngineDateAddDays(pHandle, _nValue_)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "days"
	                    pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
	                    pNew = StzEngineDateAddDays(pHandle, _nValue_)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "week"
	                    pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
	                    pNew = StzEngineDateAddDays(pHandle, _nValue_ * 7)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "weeks"
	                    pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
	                    pNew = StzEngineDateAddDays(pHandle, _nValue_ * 7)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "month"
	                    _aResult_ = _DateAddMonths(_aToday_[1], _aToday_[2], _aToday_[3], _nValue_)
	                    @nYear = _aResult_[1]
	                    @nMonth = _aResult_[2]
	                    @nDay = _aResult_[3]
	                on "months"
	                    _aResult_ = _DateAddMonths(_aToday_[1], _aToday_[2], _aToday_[3], _nValue_)
	                    @nYear = _aResult_[1]
	                    @nMonth = _aResult_[2]
	                    @nDay = _aResult_[3]
	                on "year"
	                    _aResult_ = _DateAddYears(_aToday_[1], _aToday_[2], _aToday_[3], _nValue_)
	                    @nYear = _aResult_[1]
	                    @nMonth = _aResult_[2]
	                    @nDay = _aResult_[3]
	                on "years"
	                    _aResult_ = _DateAddYears(_aToday_[1], _aToday_[2], _aToday_[3], _nValue_)
	                    @nYear = _aResult_[1]
	                    @nMonth = _aResult_[2]
	                    @nDay = _aResult_[3]
	                on "decade"
	                    pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
	                    pNew = StzEngineDateAddDays(pHandle, _nValue_ * 3650)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "decades"
	                    pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
	                    pNew = StzEngineDateAddDays(pHandle, _nValue_ * 3650)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "century"
	                    pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
	                    pNew = StzEngineDateAddDays(pHandle, _nValue_ * 36500)
	                    @nYear = StzEngineDateYear(pNew)
	                    @nMonth = StzEngineDateMonth(pNew)
	                    @nDay = StzEngineDateDay(pNew)
	                    StzEngineDateFree(pNew)
	                    StzEngineDateFree(pHandle)
	                on "centuries"
	                    pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
	                    pNew = StzEngineDateAddDays(pHandle, _nValue_ * 36500)
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

    # Reads a text with the separators / - or . (or 8 digits as ddMMyyyy) into year, month and day, without checking ranges.
    #
    #   _cDate_    the date text to read, year-first when its first part is above 100, else day-
    #              first
    #   returns    nothing; the object changes in place
    #   note       07/08/2001 is 7 August 2001
    #   warning    does not check the parts: 2001-02-45 is stored and IsValid answers FALSE
    #              afterwards; a text with no separator that is not 8 characters raises Cannot parse
    #              date string; a two-digit year raises R41
    #   see        SetDate
    def ParseStringDate(_cDate_)
        _cDate_ = trim(_cDate_)

        _aSeparators_ = ["/", "-", "."]
        _nSeparators1Len_ = len(_aSeparators_)
        for _iLoopSeparators1_ = 1 to _nSeparators1Len_
        	_cSep_ = _aSeparators_[_iLoopSeparators1_]
            if StzFindFirst(_cSep_, _cDate_) > 0
                _aParts_ = @split(_cDate_, _cSep_)
                if len(_aParts_) = 3
                    _nA_ = 0 + _aParts_[1]
                    _nB_ = 0 + _aParts_[2]
                    _nC_ = 0 + _aParts_[3]

                    if _nA_ > 100
                        @nYear = _nA_
                        @nMonth = _nB_
                        @nDay = _nC_
                        return
                    ok

                    if _nC_ > 100
                        if _nA_ > 12
                            @nDay = _nA_
                            @nMonth = _nB_
                            @nYear = _nC_
                        else
                            @nDay = _nA_
                            @nMonth = _nB_
                            @nYear = _nC_
                        ok
                        return
                    ok
                ok
            ok
        next

        if StzLen(_cDate_) = 8
            _nA_ = 0 + StzLeft(_cDate_, 2)
            _nB_ = 0 + StzRight(StzLeft(_cDate_, 4), 2)
            _nC_ = 0 + StzRight(_cDate_, 4)
            if _nC_ > 100
                @nDay = _nA_
                @nMonth = _nB_
                @nYear = _nC_
                return
            ok
        ok

        StzRaise("Cannot parse date string: " + _cDate_)

    #--- ENHANCED ARITHMETIC OPERATIONS ---#

    # Moves the date forward by n days, or back when n is negative.
    #
    #   _nDays_    the number of days to add, a fraction is dropped
    #   returns    nothing; the object changes in place
    #   note       AddDaysQ answers the object so calls chain; dates before 1970 are fine
    #   see        SubtractDays, AddWeeks, AddMonths
    def AddDays(_nDays_)
        pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
        pNew = StzEngineDateAddDays(pHandle, _nDays_)
        @nYear = StzEngineDateYear(pNew)
        @nMonth = StzEngineDateMonth(pNew)
        @nDay = StzEngineDateDay(pNew)
        StzEngineDateFree(pNew)
        StzEngineDateFree(pHandle)

	    def AddDaysQ(_nDays_)
	        This.AddDays(_nDays_)
	        return This

    # Moves the date forward by n weeks of 7 days, or back when n is negative.
    #
    #   _nWeeks_   the number of weeks to add
    #   returns    nothing; the object changes in place
    #   note       AddWeeksQ answers the object so calls chain
    #   see        SubtractWeeks, AddDays
    def AddWeeks(_nWeeks_)
        This.AddDays(_nWeeks_ * 7)

	    def AddWeeksQ(_nWeeks_)
	        This.AddWeeks(_nWeeks_)
	        return This

    # Moves the date forward by n calendar months, or back when n is negative, cutting the day to the end of a shorter month.
    #
    #   _nMonths_   the number of whole months to add
    #   returns     nothing; the object changes in place
    #   note        31 January plus 1 month is 28 February; AddMonthsQ answers the object so calls
    #               chain
    #   warning     a fractional count such as 0.5 leaves a non-integer month in the date
    #               (2026-3.50-15)
    #   see         SubtractMonths, AddYears
    def AddMonths(_nMonths_)
        _aResult_ = _DateAddMonths(@nYear, @nMonth, @nDay, _nMonths_)
        @nYear = _aResult_[1]
        @nMonth = _aResult_[2]
        @nDay = _aResult_[3]

	    def AddMonthsQ(_nMonths_)
	        This.AddMonths(_nMonths_)
	        return This

    # Moves the date forward by n calendar years, or back when n is negative, keeping 29 February only in leap years.
    #
    #   _nYears_   the number of whole years to add
    #   returns    nothing; the object changes in place
    #   note       29 February 2024 plus 1 year is 28 February 2025; AddYearsQ answers the object so
    #              calls chain
    #   warning    a fractional count such as 0.5 leaves a non-integer year in the date
    #              (2026.50-03-15)
    #   see        SubtractYears, AddMonths
    def AddYears(_nYears_)
        _aResult_ = _DateAddYears(@nYear, @nMonth, @nDay, _nYears_)
        @nYear = _aResult_[1]
        @nMonth = _aResult_[2]
        @nDay = _aResult_[3]

	    def AddYearsQ(_nYears_)
	        This.AddYears(_nYears_)
	        return This

    # Moves the date back by n days, or forward when n is negative.
    #
    #   _nDays_    the number of days to subtract
    #   returns    nothing; the object changes in place
    #   note       SubtractDaysQ answers the object so calls chain
    #   see        AddDays, SubtractWeeks
    def SubtractDays(_nDays_)
        This.AddDays(-_nDays_)

	    def SubtractDaysQ(_nDays_)
	        This.SubtractDays(_nDays_)
	        return This

    # Moves the date back by n weeks of 7 days, or forward when n is negative.
    #
    #   _nWeeks_   the number of weeks to subtract
    #   returns    nothing; the object changes in place
    #   note       SubtractWeeksQ answers the object so calls chain
    #   see        AddWeeks, SubtractDays
    def SubtractWeeks(_nWeeks_)
        This.AddDays(-_nWeeks_ * 7)

	    def SubtractWeeksQ(_nWeeks_)
	        This.SubtractWeeks(_nWeeks_)
	        return This

    # Moves the date back by n calendar months, or forward when n is negative, cutting the day to the end of a shorter month.
    #
    #   _nMonths_   the number of whole months to subtract
    #   returns     nothing; the object changes in place
    #   note        31 March minus 1 month is 28 February; SubtractMonthsQ answers the object so
    #               calls chain
    #   warning     a fractional count leaves a non-integer month in the date
    #   see         AddMonths, SubtractYears
    def SubtractMonths(_nMonths_)
        This.AddMonths(-_nMonths_)

	    def SubtractMonthsQ(_nMonths_)
	        This.SubtractMonths(_nMonths_)
	        return This

    # Moves the date back by n calendar years, or forward when n is negative, keeping 29 February only in leap years.
    #
    #   _nYears_   the number of whole years to subtract
    #   returns    nothing; the object changes in place
    #   note       SubtractYearsQ answers the object so calls chain
    #   warning    a fractional count leaves a non-integer year in the date
    #   see        AddYears, SubtractMonths
    def SubtractYears(_nYears_)
        This.AddYears(-_nYears_)

	    def SubtractYearsQ(_nYears_)
	        This.SubtractYears(_nYears_)
	        return This


    #--- SMART NAVIGATION METHODS ---#

# Returns the day after the date as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 16/03/2026
#   note       European order whatever the object holds; AddDays moves the object itself
#   see        PreviousDay, NextWeekday
def NextDay()
	_oCopy_ = This.Copy()
	_oCopy_.AddDays(1)
	return _oCopy_.Date()

# Returns the day before the date as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 14/03/2026
#   note       European order; SubtractDays moves the object itself
#   see        NextDay, PreviousWeekday
def PreviousDay()
	_oCopy_ = This.Copy()
	_oCopy_.SubtractDays(1)
	return _oCopy_.Date()

# Returns the next Monday-to-Friday day after the date as dd/MM/yyyy text, skipping the weekend.
#
#   returns    a date text such as 16/03/2026
#   note       a Friday, Saturday or Sunday gives the following Monday; the object is unchanged
#   see        PreviousWeekday, NextMonday
def NextWeekday()
    _nCurrentDay_ = This.DayOfWeek()
    _oCopy_ = This.Copy()

    if _nCurrentDay_ < 5
        _oCopy_.AddDays(1)
    else
        _oCopy_.AddDays(8 - _nCurrentDay_)
    ok
    return _oCopy_.ToString()

# Returns the day before the date as dd/MM/yyyy text, meant to skip the weekend, leaving the object unchanged.
#
#   returns    a date text such as 06/03/2026
#   note       a Monday gives the Friday before it, a Tuesday to Saturday gives the day before
#   warning    a Sunday gives the Saturday before it (08/03/2026 gives 07/03/2026) because only a
#              Monday steps back 3 days
#   see        NextWeekday, PreviousDay
def PreviousWeekday()
    _nCurrentDay_ = This.DayOfWeek()
    _oCopy_ = This.Copy()

    if _nCurrentDay_ > 1
        _oCopy_.SubtractDays(1)
    else
        _oCopy_.SubtractDays(3)
    ok
    return _oCopy_.ToString()

# Returns the first Monday strictly after the date as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 16/03/2026
#   note       a Monday gives the Monday a week later
#   see        NextWeekday
def NextMonday()
    _nDaysToAdd_ = 8 - This.DayOfWeek()
    if _nDaysToAdd_ = 8
        _nDaysToAdd_ = 7
    ok

    _oCopy_ = This.Copy()
    _oCopy_.AddDays(_nDaysToAdd_)
    return _oCopy_.ToString()

# Returns the first day of the date's month as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 01/03/2026
#   note       same answer as StartOfMonth
#   see        LastDayOfMonth, StartOfMonth
def FirstDayOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, @nMonth, 1 ])
    return _oCopy_.ToString()

# Returns the last day of the date's month as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 31/03/2026
#   note       leap years are honoured: 29/02/2024
#   see        FirstDayOfMonth, EndOfMonth
def LastDayOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, @nMonth, _DaysInMonth(@nYear, @nMonth) ])
    return _oCopy_.ToString()

# Returns the first day of the date's month as dd/MM/yyyy text; the Q form answers a new date object instead.
#
#   returns    a date text such as 01/03/2026
#   note       StartOfMonthQ answers a copy and leaves the object unchanged, like the text form
#   see        EndOfMonth, FirstDayOfMonth
def StartOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, @nMonth, 1 ])
    return _oCopy_.ToString()

    def StartOfMonthQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, @nMonth, 1 ])
        return _oCopy_

# Returns the last day of the date's month as dd/MM/yyyy text; the Q form answers a new date object instead.
#
#   returns    a date text such as 31/03/2026
#   note       EndOfMonthQ answers a copy and leaves the object unchanged
#   see        StartOfMonth, LastDayOfMonth
def EndOfMonth()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, @nMonth, _DaysInMonth(@nYear, @nMonth) ])
    return _oCopy_.ToString()

    def EndOfMonthQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, @nMonth, _DaysInMonth(@nYear, @nMonth) ])
        return _oCopy_

# Returns 1 January of the date's year as dd/MM/yyyy text; the Q form answers a new date object instead.
#
#   returns    a date text such as 01/01/2026
#   note       StartOfYearQ answers a copy and leaves the object unchanged
#   see        EndOfYear, StartOfMonth
def StartOfYear()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, 1, 1 ])
    return _oCopy_.ToString()

    def StartOfYearQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, 1, 1 ])
        return _oCopy_

# Returns 31 December of the date's year as dd/MM/yyyy text; the Q form answers a new date object instead.
#
#   returns    a date text such as 31/12/2026
#   note       EndOfYearQ answers a copy and leaves the object unchanged
#   see        StartOfYear, EndOfMonth
def EndOfYear()
    _oCopy_ = This.Copy()
    _oCopy_.SetDate([ @nYear, 12, 31 ])
    return _oCopy_.ToString()

    def EndOfYearQ()
        _oCopy_ = This.Copy()
        _oCopy_.SetDate([ @nYear, 12, 31 ])
        return _oCopy_

# Returns the first day of the following month as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 01/04/2026
#   note       the Q form answers a new date object
#   see        DayBeforeMonthStart, NextStartOfMonth
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

# Returns the last day of the previous month as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 28/02/2026
#   note       the Q form answers a new date object
#   see        DayAfterMonthEnd, PreviousEndOfMonth
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

# Returns 1 January of the following year as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 01/01/2027
#   note       the Q form answers a new date object
#   see        DayBeforeYearStart
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

# Returns 31 December of the previous year as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 31/12/2025
#   note       the Q form answers a new date object
#   see        DayAfterYearEnd
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

# Returns the last day of the month after the date's month as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 30/04/2026
#   note       the Q form answers a new date object
#   see        PreviousEndOfMonth, EndOfMonth
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

# Returns the last day of the month before the date's month as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 28/02/2026
#   note       the Q form answers a new date object
#   see        NextEndOfMonth, EndOfMonth
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

# Returns the first day of the month after the date's month as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 01/04/2026
#   note       the Q form answers a new date object
#   see        PreviousStartOfMonth, StartOfMonth
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

# Returns the first day of the month before the date's month as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 01/02/2026
#   note       the Q form answers a new date object
#   see        NextStartOfMonth, StartOfMonth
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

# Returns the middle day of the date's month, the day number rounded up from half the month length, as dd/MM/yyyy text.
#
#   returns    a date text such as 16/03/2026
#   note       the 16th for 31 days, the 15th for 30 days and for 29 days, the 14th for 28 days; the
#              object is unchanged
#   see        StartOfMonth, EndOfMonth
def MidMonth()
    _oCopy_ = This.Copy()
    _nMid_ = ceil(_oCopy_.DaysInMonthN() / 2)
    _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), _nMid_ ])
    return _oCopy_.ToString()

    def MidMonthQ()
        _oCopy_ = This.Copy()
        _nMid_ = ceil(_oCopy_.DaysInMonthN() / 2)
        _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), _nMid_ ])
        return _oCopy_

# Returns the first Monday-to-Friday day of the date's month as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 02/03/2026
#   note       the Q form answers a new date object
#   see        LastWeekdayOfMonth, StartOfMonth
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

# Returns the last Monday-to-Friday day of the date's month as dd/MM/yyyy text, leaving the object unchanged.
#
#   returns    a date text such as 31/03/2026
#   note       the Q form answers a new date object
#   see        FirstWeekdayOfMonth, EndOfMonth
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

    # Applies one of the operators + - < <= > >= = between the date and a number, a text or another date.
    #
    #   op         the operator text: + - < <= > >= =
    #   v          the right-hand value: a number of days, a phrase such as 2 weeks, a date text or
    #              a stzDate object
    #   returns    for + and - with a number or text, the new date as dd/MM/yyyy text; for - with a
    #              date, the number of days between; for a comparison, TRUE or FALSE
    #   note       a number means days: date + 3 moves 3 days; comparisons accept a date object or a
    #              date text
    #   warning    + and - change the object itself, unlike arithmetic on numbers; date minus date
    #              is the absolute number of days, never negative; a unit other than days, weeks,
    #              months or years raises Invalid unit!; a list as right-hand side of - or a
    #              comparison raises Unsupported value!; + with a list and any other operator answer
    #              nothing
    #   see        ParseOperation, DaysTo
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


	# Adds or subtracts an amount written as a number and a unit, such as 3 days or 2 weeks.
	#
	#   cOperation   the amount: a number and a unit, such as 3 days or 1 year, with units day,
	#                week, month or year in singular or plural
	#   cOperator    the operator text: - subtracts, anything else adds
	#   returns      nothing; the object changes in place
	#   note         does not return the new date
	#   warning      raises Invalid operation format when the text is only a number, and Invalid
	#                unit! for hours or fortnights; a space doubled between number and unit reads as
	#                an empty unit
	#   see          operator, AddDays
	def ParseOperation(cOperation, cOperator)
	    _aValueUnit_ = ExtractValueAndUnit(cOperation)

	    if _aValueUnit_ = ""
	        StzRaise("Invalid operation format. Use 'n days/weeks/months/years'")
	    ok

	    _nValue_ = _aValueUnit_[1]
	    _cUnit_ = _aValueUnit_[2]

	    if cOperator = "-"
	        _nValue_ = -_nValue_
	    ok

	    switch _cUnit_
	        on "day"
	            This.AddDays(_nValue_)

	        on "days"
	            This.AddDays(_nValue_)

	        on "week"
	            This.AddWeeks(_nValue_)

	        on "weeks"
	            This.AddWeeks(_nValue_)

	        on "month"
	            This.AddMonths(_nValue_)

	        on "months"
	            This.AddMonths(_nValue_)

	        on "year"
	            This.AddYears(_nValue_)

	        on "years"
	            This.AddYears(_nValue_)

	        other
	            StzRaise("Invalid unit! Use 'days', 'weeks', 'months', or 'years'.")
	    off

    #--- COMPARISON METHODS ---#

    # Returns the signed number of days from the date to another one, negative when the other date is earlier.
    #
    #   _oOtherDate_   the other date: a stzDate object, a date text, a list [ y, m, d ] or a hash
    #                  with :Year, :Month and :Day
    #   returns        a number of days; 10 from 2026-03-15 to 2026-03-25
    #   note           works across 1970: 25822 days from 1955-07-04 to 2026-03-15
    #   warning        a list or hash held in a variable is REPLACED in the caller by a stzDate
    #                  object (the call assigns to its own parameter, which Ring shares with the
    #                  caller); a number raises Parameter must be a stzDate object or date string
    #   see            WeeksTo, MonthsTo, IsBefore
    def DaysTo(_oOtherDate_)

	if isList(_oOtherDate_) and len(_oOtherDate_) = 3
		if IsListOfNumbers(_oOtherDate_)
			_cOtherDate_ = '' + _oOtherDate_[1] + "-" + _oOtherDate_[2] + "-" + _oOtherDate_[3]
			_oOtherDate_ = _cOtherDate_

		but IsHashList(_oOtherDate_) and HasKeys(_oOtherDate_, [ :Year, :Month, :Day ])
			_cOtherDate_ = '' + _oOtherDate_[:Year] + "-" + _oOtherDate_[:Month] + "-" + _oOtherDate_[:Day]
			_oOtherDate_ = _cOtherDate_
		ok
	ok

        if isString(_oOtherDate_)
            _oTempDate_ = new stzDate(_oOtherDate_)
	    _oOtherDate_ = _oTempDate_
        ok

        if not isObject(_oOtherDate_) or not ring_classname(_oOtherDate_) = "stzdate"
            StzRaise("Parameter must be a stzDate object or date string")
        ok

        pHandle1 = StzEngineDateNew(@nYear, @nMonth, @nDay)
        pHandle2 = StzEngineDateNew(_oOtherDate_.Year(), _oOtherDate_.MonthN(), _oOtherDate_.DayN())
        # Engine's stz_date_diff_days(a, b) returns a - b. The semantic
        # of DaysTo is "days from this to other", which is other - this
        # -- so call with args swapped.
        _nResult_ = StzEngineDateDiffDays(pHandle2, pHandle1)
        StzEngineDateFree(pHandle1)
        StzEngineDateFree(pHandle2)
	return _nResult_

	def DaysToN(_oOtherDate_)
		return This.DaysTo(_oOtherDate_)

	def DaysToDate(_oOtherDate_)
		return This.DaysTo(_oOtherDate_)

	def DaysToDateN(_oOtherDate_)
		return This.DaysTo(_oOtherDate_)

    # Returns the number of whole weeks from the date to another one, rounded down, so negative counts round away from zero.
    #
    #   _oOtherDate_   the other date: a stzDate object, a date text, a list or a hash
    #   returns        a number of weeks; 1 for 10 days, -2 for -9 days
    #   note           floor of days divided by 7
    #   warning        a list or hash variable is replaced in the caller by a stzDate object, as in
    #                  DaysTo
    #   see            DaysTo, MonthsTo
    def WeeksTo(_oOtherDate_)
        return floor(This.DaysTo(_oOtherDate_) / 7)

	def WeeksToN(_oOtherDate_)
		return this.WeeksTo(_oOtherDate_)

	def WeeksToDate(_oOtherDate_)
		return this.WeeksTo(_oOtherDate_)

	def WeeksToDateN(_oOtherDate_)
		return this.WeeksTo(_oOtherDate_)

    # Returns the number of calendar months from the date to another one, counting month and year numbers only, not days.
    #
    #   _oOtherDate_   the other date as a stzDate object
    #   returns        a number of months; 2 from March to May
    #   note           2026-01-31 to 2026-02-01 is 1
    #   warning        raises Can't create the stzDate object for a text, a list or a hash (the
    #                  parameter is overwritten by the object being built, which then reads it);
    #                  only a stzDate object works
    #   see            YearsTo, DaysTo
    def MonthsTo(_oOtherDate_)
        if isList(_oOtherDate_) and len(_oOtherDate_) = 3
	        if IsListOfNumbers(_oOtherDate_)
	            _oOtherDate_ = new stzDate('' + _oOtherDate_[1] + "-" + _oOtherDate_[2] + "-" + _oOtherDate_[3])
	        but IsHashList(_oOtherDate_) and HasKeys(_oOtherDate_, [ :Year, :Month, :Day ])
	            _oOtherDate_ = new stzDate('' + _oOtherDate_[:Year] + "-" + _oOtherDate_[:Month] + "-" + _oOtherDate_[:Day])
	        ok
        ok

        if isString(_oOtherDate_)
            _oOtherDate_ = new stzDate(_oOtherDate_)
        ok

        _nYears_ = _oOtherDate_.Year() - This.Year()
        _nMonths_ = _oOtherDate_.MonthN() - This.MonthN()

        return (_nYears_ * 12) + _nMonths_

	def MonthsToN(_oOtherDate_)
		return This.MonthsTo(_oOtherDate_)

	def MonthsToDate(_oOtherDate_)
		return This.MonthsTo(_oOtherDate_)

	def MonthsToDateN(_oOtherDate_)
		return This.MonthsTo(_oOtherDate_)

    # Returns the difference of the year numbers from the date to another one, ignoring month and day.
    #
    #   _oOtherDate_   the other date as a stzDate object
    #   returns        a number of years; 1 from 2026-12-31 to 2027-01-01
    #   note           a difference of one calendar day over New Year is 1 year
    #   warning        raises for a text, a list or a hash, as MonthsTo does; only a stzDate object
    #                  works
    #   see            MonthsTo, Age
    def YearsTo(_oOtherDate_)
        if isList(_oOtherDate_) and len(_oOtherDate_) = 3
	        if IsListOfNumbers(_oOtherDate_)
	            _oOtherDate_ = new stzDate('' + _oOtherDate_[1] + "-" + _oOtherDate_[2] + "-" + _oOtherDate_[3])
	        but IsHashList(_oOtherDate_) and HasKeys(_oOtherDate_, [ :Year, :Month, :Day ])
	            _oOtherDate_ = new stzDate('' + _oOtherDate_[:Year] + "-" + _oOtherDate_[:Month] + "-" + _oOtherDate_[:Day])
	        ok
        ok

        if isString(_oOtherDate_)
            _oOtherDate_ = new stzDate(_oOtherDate_)
        ok

        return _oOtherDate_.Year() - This.Year()

	def YearsToN(_oOtherDate_)
		return This.YearsTo(_oOtherDate_)

	def YearsToDate(_oOtherDate_)
		return This.YearsTo(_oOtherDate_)

	def YearsToDateN(_oOtherDate_)
		return This.YearsTo(_oOtherDate_)


    # TRUE if the date comes strictly before the other date, compared by calendar day.
    #
    #   _oOtherDate_   the other date: a stzDate object, a date text, a list [ y, m, d ] or a hash
    #                  with :Year, :Month and :Day
    #   returns        TRUE or FALSE
    #   note           the same day gives FALSE
    #   warning        a list or hash variable is replaced in the caller by a stzDate object, as in
    #                  DaysTo
    #   see            IsAfter, IsEqualTo, DaysTo
    def IsBefore(_oOtherDate_)
        return This.DaysTo(_oOtherDate_) > 0

    # TRUE if the date comes strictly after the other date, compared by calendar day.
    #
    #   _oOtherDate_   the other date: a stzDate object, a date text, a list or a hash
    #   returns        TRUE or FALSE
    #   note           the same day gives FALSE
    #   warning        a list or hash variable is replaced in the caller by a stzDate object, as in
    #                  DaysTo
    #   see            IsBefore, IsEqualTo
    def IsAfter(_oOtherDate_)
        return This.DaysTo(_oOtherDate_) < 0

    # TRUE if both dates fall on the same calendar day.
    #
    #   _oOtherDate_   the other date: a stzDate object, a date text, a list or a hash
    #   returns        TRUE or FALSE
    #   note           15/03/2026 and 2026-03-15 are equal
    #   warning        a list or hash variable is replaced in the caller by a stzDate object, as in
    #                  DaysTo
    #   see            IsBefore, IsAfter
    def IsEqualTo(_oOtherDate_)
        return This.DaysTo(_oOtherDate_) = 0

		# TRUE if both dates fall on the same calendar day, as IsEqualTo does.
		#
		#   _oOtherDate_   the other date: a stzDate object, a date text, a list or a hash
		#   returns        TRUE or FALSE
		#   warning        same list and hash caveat as DaysTo
		#   see            IsEqualTo
		def IsEqual(_oOtherDate_)
			return This.DaysTo(_oOtherDate_) = 0

    # TRUE if both dates share the week number and the year number, the week being the one WeekNumber reports.
    #
    #   _oOtherDate_   the other date as a stzDate object
    #   returns        TRUE or FALSE
    #   note           weeks start on Monday and the week holding 1 January is week 1, so a week
    #                  that straddles New Year counts as two
    #   warning        raises Can't create the stzDate object for a text, a list or a hash; only a
    #                  stzDate object works
    #   see            IsSameMonth, WeekNumber
    def IsSameWeek(_oOtherDate_)
	    if isList(_oOtherDate_) and len(_oOtherDate_) = 3
	        if IsListOfNumbers(_oOtherDate_)
	            _oOtherDate_ = new stzDate('' + _oOtherDate_[1] + "-" + _oOtherDate_[2] + "-" + _oOtherDate_[3])
	        but IsHashList(_oOtherDate_) and HasKeys(_oOtherDate_, [ :Year, :Month, :Day ])
	            _oOtherDate_ = new stzDate('' + _oOtherDate_[:Year] + "-" + _oOtherDate_[:Month] + "-" + _oOtherDate_[:Day])
	        ok
	    ok

        if isString(_oOtherDate_)
            _oOtherDate_ = new stzDate(_oOtherDate_)
        ok
        return This.WeekNumber() = _oOtherDate_.WeekNumber() and This.YearN() = _oOtherDate_.YearN()

    # TRUE if both dates fall in the same month of the same year.
    #
    #   _oOtherDate_   the other date as a stzDate object
    #   returns        TRUE or FALSE
    #   note           the same month of another year gives FALSE
    #   warning        raises for a text, a list or a hash; only a stzDate object works
    #   see            IsSameYear, IsSameWeek
    def IsSameMonth(_oOtherDate_)
	    if isList(_oOtherDate_) and len(_oOtherDate_) = 3
	        if IsListOfNumbers(_oOtherDate_)
	            _oOtherDate_ = new stzDate('' + _oOtherDate_[1] + "-" + _oOtherDate_[2] + "-" + _oOtherDate_[3])
	        but IsHashList(_oOtherDate_) and HasKeys(_oOtherDate_, [ :Year, :Month, :Day ])
	            _oOtherDate_ = new stzDate('' + _oOtherDate_[:Year] + "-" + _oOtherDate_[:Month] + "-" + _oOtherDate_[:Day])
	        ok
	    ok

        if isString(_oOtherDate_)
            _oOtherDate_ = new stzDate(_oOtherDate_)
        ok
        return This.MonthN() = _oOtherDate_.MonthN() and This.YearN() = _oOtherDate_.YearN()

    # TRUE if both dates fall in the same year.
    #
    #   _oOtherDate_   the other date as a stzDate object
    #   returns        TRUE or FALSE
    #   warning        raises for a text, a list or a hash; only a stzDate object works
    #   see            IsSameMonth
    def IsSameYear(_oOtherDate_)
	    if isList(_oOtherDate_) and len(_oOtherDate_) = 3
	        if IsListOfNumbers(_oOtherDate_)
	            _oOtherDate_ = new stzDate('' + _oOtherDate_[1] + "-" + _oOtherDate_[2] + "-" + _oOtherDate_[3])
	        but IsHashList(_oOtherDate_) and HasKeys(_oOtherDate_, [ :Year, :Month, :Day ])
	            _oOtherDate_ = new stzDate('' + _oOtherDate_[:Year] + "-" + _oOtherDate_[:Month] + "-" + _oOtherDate_[:Day])
	        ok
	    ok

        if isString(_oOtherDate_)
            _oOtherDate_ = new stzDate(_oOtherDate_)
        ok
        return This.YearN() = _oOtherDate_.YearN()

    #--- UTILITY CHECKS ---#

    # TRUE if the date is a Saturday or a Sunday.
    #
    #   returns    TRUE or FALSE
    #   note       2026-03-14 and 2026-03-15 are weekend days
    #   see        IsWeekday, DayOfWeek
    def IsWeekend()
        _nDay_ = This.DayOfWeek()
        return (_nDay_ = 6 or _nDay_ = 7)

    # TRUE if the date is a Monday, Tuesday, Wednesday, Thursday or Friday.
    #
    #   returns    TRUE or FALSE
    #   note       holidays are not looked at
    #   see        IsWeekend
    def IsWeekday()
        return not This.IsWeekend()

    # TRUE if the date is today's date, read from the clock.
    #
    #   returns    TRUE or FALSE
    #   note       follows StzFreezeClock, so a test can pin today
    #   see        IsYesterday, IsTomorrow
    def IsToday()
        _aToday_ = _TodayYMD()
        if @nYear = _aToday_[1] and @nMonth = _aToday_[2] and @nDay = _aToday_[3]
			return 1
		else
			return 0
		ok

    # TRUE if the date is the day before today, read from the clock.
    #
    #   returns    TRUE or FALSE
    #   note       follows StzFreezeClock
    #   see        IsToday, IsTomorrow
    def IsYesterday()
        _aToday_ = _TodayYMD()
        pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
        pYesterday = StzEngineDateAddDays(pHandle, -1)
        _nY_ = StzEngineDateYear(pYesterday)
        _nM_ = StzEngineDateMonth(pYesterday)
        _nD_ = StzEngineDateDay(pYesterday)
        StzEngineDateFree(pYesterday)
        StzEngineDateFree(pHandle)
        return @nYear = _nY_ and @nMonth = _nM_ and @nDay = _nD_

    # TRUE if the date is the day after today, read from the clock.
    #
    #   returns    TRUE or FALSE
    #   note       follows StzFreezeClock
    #   see        IsToday, IsYesterday
    def IsTomorrow()
        _aToday_ = _TodayYMD()
        pHandle = StzEngineDateNew(_aToday_[1], _aToday_[2], _aToday_[3])
        pTomorrow = StzEngineDateAddDays(pHandle, 1)
        _nY_ = StzEngineDateYear(pTomorrow)
        _nM_ = StzEngineDateMonth(pTomorrow)
        _nD_ = StzEngineDateDay(pTomorrow)
        StzEngineDateFree(pTomorrow)
        StzEngineDateFree(pHandle)
        return @nYear = _nY_ and @nMonth = _nM_ and @nDay = _nD_

    # Returns the number of calendar years between the date's year and the current year, never negative.
    #
    #   returns    a number of years
    #   note       follows StzFreezeClock
    #   warning    counts year numbers only, so someone born on 1990-12-31 is 36 on 2026-03-15
    #              though 35 years old, and a date in the future also gives a positive count
    #   see        YearsTo, ToRelative
    def Age()
        _oToday_ = new stzDate("")
        _nYears_ = This.YearsTo(_oToday_)
        if _nYears_ < 0
            _nYears_ = -_nYears_
        ok
        return _nYears_

    #--- ENHANCED GETTERS ---#

    # Returns the year of the date as a number.
    #
    #   returns    a number such as 2026
    #   note       same as YearN
    #   see        Month, Day
    def Year()
        return @nYear

    	# Returns the year of the date as a number.
    	#
    	#   returns    a number such as 2026
    	#   see        Year
    	def YearN()
        	return @nYear

    # Returns the English name of the date's month, such as March.
    #
    #   returns    a month name as text
    #   note       not the month number: MonthN gives that
    #   see        MonthN, MonthInLanguage
    def Month()
        return GetMonthName(@nMonth)

	# Returns the English name of the date's month, such as March.
	#
	#   returns    a month name as text
	#   see        Month, MonthN
	def MonthName()
		return GetMonthName(@nMonth)

    # Returns the month of the date as a number from 1 to 12.
    #
    #   returns    a number from 1 to 12
    #   see        Month, MonthNumberInString
    def MonthN()
        return @nMonth

	    # Returns the month of the date as a number from 1 to 12.
	    #
	    #   returns    a number from 1 to 12
	    #   see        MonthN
	    def MonthNumber()
	        return @nMonth

    # Returns the month number as two characters with a leading zero, such as 03.
    #
    #   returns    a text of two digits
    #   see        MonthN
    def MonthNumberInString()
        return _PadLeft("" + @nMonth, 2, "0")

    # Returns the name of the date's month in the given language.
    #
    #   _cLanguage_   the language as a lowercase text such as french, or a symbol such as :French
    #   returns       a month name as text
    #   note          march is Mars in French
    #   warning       a text that is not all lowercase (French, Arabic) and any other language
    #                 answer the English name; an empty text uses the current language, English
    #   see           MonthIn, DayInLanguage
    def MonthInLanguage(_cLanguage_)
        return GetMonthNameXT(@nMonth, _cLanguage_)

    def MonthIn(_cLanguage_)
        return This.MonthInLanguage(_cLanguage_)

    # Returns the first three letters of the English month name, such as Mar.
    #
    #   returns    a text of three letters
    #   see        Month, DayShort
    def MonthShort()
        _cMonth_ = This.Month()
        return StzLeft(_cMonth_, 3)

    # Returns the English name of the weekday, such as Thursday.
    #
    #   returns    a weekday name as text
    #   note       the NAME of the day, not the day of the month: DayN gives that
    #   see        DayN, DayOfWeek
    def Day()
        return GetDayName(This.DayOfWeek())

	def DayName()
		return This.Day()

    # Returns the day of the month as a number from 1 to 31.
    #
    #   returns    a number from 1 to 31
    #   see        Day, DayOfWeek
    def DayN()
        return @nDay

   	 	# Returns the day of the month as a number from 1 to 31.
   	 	#
   	 	#   returns    a number from 1 to 31
   	 	#   see        DayN
   	 	def DayNumber()
        	return @nDay

    # Returns the name of the weekday in the given language.
    #
    #   _cLanguage_   the language as a lowercase text such as french, or a symbol such as :French
    #   returns       a weekday name as text
    #   note          sunday is Dimanche in French
    #   warning       a text that is not all lowercase (French, Arabic) and any other language
    #                 answer the English name; an empty text uses English
    #   see           DayIn, MonthInLanguage
    def DayInLanguage(_cLanguage_)
        return GetDayNameXT(This.DayOfWeek(), _cLanguage_)

    # Returns the name of the weekday in the given language.
    #
    #   _cLanguage_   the language as a lowercase text such as french, or a symbol such as :French
    #   returns       a weekday name as text
    #   warning       same language rules as DayInLanguage
    #   see           DayInLanguage
    def DayIn(_cLanguage_)
        return DayInLanguage(_cLanguage_)

    # Returns the first three letters of the English weekday name, such as Thu.
    #
    #   returns    a text of three letters
    #   see        Day, MonthShort
    def DayShort()
        _cDay_ = This.Day()
        return StzLeft(_cDay_, 3)

    # Returns the position of the weekday in the week, 1 for Monday up to 7 for Sunday.
    #
    #   returns    a number from 1 to 7
    #   note       Monday is 1 and Sunday is 7, not the other way
    #   see        Day, IsWeekend
    def DayOfWeek()
        pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
        _nResult_ = StzEngineDateDayOfWeek(pHandle)
        StzEngineDateFree(pHandle)
        return _nResult_

    	def DayOfWeekN()
        	return This.DayOfWeek()

    # Returns the position of the date in its year, 1 for 1 January.
    #
    #   returns    a number from 1 to 366
    #   note       15 March 2026 is day 74
    #   see        WeekNumber, DaysInYear
    def DayOfYear()
        pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
        _nResult_ = StzEngineDateDayOfYear(pHandle)
        StzEngineDateFree(pHandle)
        return _nResult_

    	def DayOfYearN()
       		 return This.DayOfYear()

    # Returns the week of the year, with weeks starting on Monday and the week holding 1 January numbered 1.
    #
    #   returns    a number from 1 to 53
    #   note       2026-03-15 is week 11
    #   warning    not the ISO 8601 week: 2025-12-31 is week 53 here and week 1 of 2026 in ISO
    #   see        DayOfYear, IsSameWeek
    def WeekNumber()
        pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
        _nDayOfYear_ = StzEngineDateDayOfYear(pHandle)
        StzEngineDateFree(pHandle)

        pJan1 = StzEngineDateNew(@nYear, 1, 1)
        _nJan1DayOfWeek_ = StzEngineDateDayOfWeek(pJan1)
        StzEngineDateFree(pJan1)

        _nWeek_ = floor((_nDayOfYear_ + _nJan1DayOfWeek_ - 2) / 7) + 1

        if _nWeek_ = 0
            _nWeek_ = 52
            pDec31 = StzEngineDateNew(@nYear-1, 12, 31)
            _nDec31Dow_ = StzEngineDateDayOfWeek(pDec31)
            StzEngineDateFree(pDec31)
            if _nDec31Dow_ = 4
                _nWeek_ = 53
            ok
        ok

        return _nWeek_

    # Returns the number of days in the date's month, 29 for February of a leap year.
    #
    #   returns    a number from 28 to 31
    #   note       the century rule is applied: 1900 is not a leap year
    #   see        DaysInYear, IsLeapYear
    def DaysInMonth()
        return _DaysInMonth(@nYear, @nMonth)

    	# Returns the number of days in the date's month, 29 for February of a leap year, as a number.
    	#
    	#   returns    a number from 28 to 31
    	#   note       same answer as DaysInMonth; N marks a numeric result
    	#   see        DaysInMonth, DaysInYearN
    	def DaysInMonthN()
        	return _DaysInMonth(@nYear, @nMonth)

    # Returns 366 for a leap year and 365 otherwise.
    #
    #   returns    365 or 366
    #   see        DaysInMonth, IsLeapYear
    def DaysInYear()
        if _IsLeapYear(@nYear) return 366 else return 365 ok

    	# Returns 366 for a leap year and 365 otherwise, as a number.
    	#
    	#   returns    365 or 366
    	#   note       same answer as DaysInYear; N marks a numeric result
    	#   see        DaysInYear, DaysInMonthN
    	def DaysInYearN()
        	if _IsLeapYear(@nYear) return 366 else return 365 ok

    # TRUE if the date's year is a leap year, by the Gregorian rule of 4, 100 and 400.
    #
    #   returns    TRUE or FALSE
    #   note       2000 and 2024 are leap years, 1900 and 2026 are not
    #   see        DaysInYear
    def IsLeapYear()
        return _IsLeapYear(@nYear)

		# TRUE if the date's year is a leap year, as IsLeapYear says.
		#
		#   returns    TRUE or FALSE
		#   see        IsLeapYear
		def ISLeap()
			return _IsLeapYear(@nYear)

    #--- HUMAN-READABLE FORMATTING ---#

    # Returns today, tomorrow or yesterday for those days, a count of days for the next or last 7, else a long date.
    #
    #   returns    text such as tomorrow, In 3 days, 3 days ago or Monday, March 23rd, 2026
    #   note       follows StzFreezeClock; English only; the long form has an ordinal day (1st, 2nd,
    #              3rd, 4th)
    #   warning    the future form starts with a capital (In 3 days) and the past form does not (3
    #              days ago)
    #   see        ToRelative, ToLong
    def ToHuman()
	    _oToday_ = new stzDate("")
	    _nDays_ = This.DaysTo(_oToday_)
	    _nDays_ = -_nDays_

	    if _nDays_ = 0
	        return "today"

	    but _nDays_ = 1
	        return "tomorrow"

	    but _nDays_ = -1
	        return "yesterday"

	    but _nDays_ > 0 and _nDays_ <= 7
	        return "In " + _nDays_ + " day" + Iff(_nDays_=1, "", "s")

	    but _nDays_ < 0 and _nDays_ >= -7
	        return '' + (-_nDays_) + " day" + Iff(_nDays_=-1, "", "s") + " ago"

	    else
	        _nDay_ = This.DayN()
	        _cDaySuffix_ = DayOrdinalSuffix(_nDay_)
	        _cHuman_ = This.Day() + ", " + This.Month() + " " + _nDay_ + _cDaySuffix_ + ", " + This.Year()
	        return _cHuman_
	    ok


    # Returns today, tomorrow or yesterday, a count of days or weeks within a month of today, else the date as dd/MM/yyyy.
    #
    #   returns    text such as in 3 days, in 1 week, 2 weeks ago or 20/04/2026
    #   note       follows StzFreezeClock; 8 to 14 days away is 1 week, 15 to 30 days is the whole
    #              weeks, further away is the plain date
    #   see        ToHuman, ToString
    def ToRelative()
	    _oToday_ = new stzDate("")
	    _nDays_ = This.DaysTo(_oToday_)
	    _nDays_ = -_nDays_

	    if _nDays_ = 0
	        return "today"

	    but _nDays_ = 1
	        return "tomorrow"

	    but _nDays_ = -1
	        return "yesterday"

	    but _nDays_ > 1 and _nDays_ <= 7
	        return "in " + _nDays_ + " days"

	    but _nDays_ > 7 and _nDays_ <= 14
	        return "in 1 week"

	    but _nDays_ > 14 and _nDays_ <= 30
	        _nWeeks_ = floor(_nDays_ / 7)
	        return "in " + _nWeeks_ + " weeks"

	    but _nDays_ < -1 and _nDays_ >= -7
	        return '' + (-_nDays_) + " days ago"

	    but _nDays_ < -7 and _nDays_ >= -14
	        return "1 week ago"

	    but _nDays_ < -14 and _nDays_ >= -30
	        _nWeeks_ = floor((-_nDays_) / 7)
	        return '' + _nWeeks_ + " weeks ago"

	    else
	        return This.ToString()
	    ok


    # Returns the date as dd/MM/yyyy text, the European order.
    #
    #   returns    a text such as 15/03/2026
    #   note       the year is not padded: year 999 gives 15/03/999; Content and Date give the same
    #              text, and ToStringXT takes a format
    #   see        ToISO8601, ToAmerican
    def ToString()
        return This.ToStringXT("")

		def Content()
			return This.ToString()

		def Date()
			return This.ToString()

    def ToStringXT(_cFormat_)
        if _cFormat_ = ""
            _cFormat_ = $cDefaultDateFormat
        ok

        _cLowerFormat_ = StzLower(_cFormat_)
        _nDateFormats1Len_ = len($aDateFormats)
        for _iLoopDateFormats1_ = 1 to _nDateFormats1Len_
        	_aFormat_ = $aDateFormats[_iLoopDateFormats1_]
            if StzLower(_aFormat_[1]) = _cLowerFormat_
                _cFormat_ = _aFormat_[2]
                exit
            ok
        next

        return _DateFormatString(@nYear, @nMonth, @nDay, _cFormat_)

    # Returns the date as yyyy-MM-dd text.
    #
    #   returns    a text such as 2026-03-15
    #   note       the year is not padded to four digits before 1000
    #   see        ToString, ToAmerican
    def ToISO8601()
        return This.ToStringXT("yyyy-MM-dd")

    # Returns the date as dd/MM/yyyy text.
    #
    #   returns    a text such as 15/03/2026
    #   see        ToAmerican, ToISO8601
    def ToEuropean()
        return This.ToStringXT("dd/MM/yyyy")

    # Returns the date as MM/dd/yyyy text, month first.
    #
    #   returns    a text such as 03/15/2026
    #   note       the American text is not read back correctly by the constructor, which reads day
    #              first
    #   see        ToEuropean, ToISO8601
    def ToAmerican()
        return This.ToStringXT("MM/dd/yyyy")

    # Returns the date as a short English text such as Thu 5 Mar, with weekday, day and month.
    #
    #   returns    a text such as Thu 5 Mar
    #   see        ToLong, ToString
    def ToShort()
        return This.DayShort() + " " + This.DayN() + " " + This.MonthShort()

    # Returns the date as a long English text such as Thursday, March 5, 2026.
    #
    #   returns    a text such as Thursday, March 5, 2026
    #   note       the day has no leading zero and no ordinal suffix
    #   see        ToShort, ToHuman
    def ToLong()
        return This.Day() + ", " + This.Month() + " " + This.DayN() + ", " + This.Year()

    #--- JULIAN DAY METHODS ---#

    # Returns the Julian day number of the date, the count of days since 4713 BC, from the Gregorian formula.
    #
    #   returns    a whole number; 2461115 for 2026-03-15
    #   note       2000-01-01 is 2451545 and 1970-01-01 is 2440588; works before 1970
    #   see        FromJulianDay, DayOfYear
    def ToJulianDay()
        _nA_ = floor((14 - @nMonth) / 12)
        _nY_ = @nYear + 4800 - _nA_
        _nM_ = @nMonth + 12 * _nA_ - 3
        return @nDay + floor((153 * _nM_ + 2) / 5) + 365 * _nY_ + floor(_nY_ / 4) - floor(_nY_ / 100) + floor(_nY_ / 400) - 32045

    # Sets the date to the one with the given Julian day number, the inverse of ToJulianDay.
    #
    #   nJulianDay   the Julian day number, a whole number such as 2451545
    #   returns      nothing; the object changes in place
    #   note         FromJulianDayQ answers the object so calls chain; 2451545 gives 2000-01-01
    #   warning      a fractional number gives a fractional day (2000-01-1.50)
    #   see          ToJulianDay
    def FromJulianDay(nJulianDay)
        _nA_ = nJulianDay + 32044
        _nB_ = floor((4 * _nA_ + 3) / 146097)
        _nC_ = _nA_ - floor(146097 * _nB_ / 4)
        _nD_ = floor((4 * _nC_ + 3) / 1461)
        _nE_ = _nC_ - floor(1461 * _nD_ / 4)
        _nM_ = floor((5 * _nE_ + 2) / 153)
        @nDay = _nE_ - floor((153 * _nM_ + 2) / 5) + 1
        @nMonth = _nM_ + 3 - 12 * floor(_nM_ / 10)
        @nYear = 100 * _nB_ + _nD_ - 4800 + floor(_nM_ / 10)

	    def FromJulianDayQ(nJulianDay)
	        This.FromJulianDay(nJulianDay)
	        return This

    #--- BATCH OPERATIONS ---#

    # TRUE if the date falls strictly after the start date and strictly before the end date.
    #
    #   _oStartDate_   the lower bound as a stzDate object
    #   _oEndDate_     the upper bound as a stzDate object
    #   returns        TRUE or FALSE
    #   note           the end bound may be written [ :And, oEnd ]
    #   warning        both bounds are excluded, a date equal to a bound gives FALSE; a text, a list
    #                  or a hash as bound raises (Can't create the stzDate object, or Cannot parse
    #                  date string: --); only stzDate objects work; bounds in the wrong order give
    #                  FALSE
    #   see            IsBefore, IsAfter
    def IsBetween(_oStartDate_, _oEndDate_)
	if CheckParams()
		if isList(_oEndDate_) and IsAndNamedParamList(_oEndDate_)
			_oEndDate_ = _oEndDate_[2]
		ok
	ok

        if isList(_oStartDate_) and len(_oStartDate_) = 3
	        if IsListOfNumbers(_oStartDate_)
	            _oStartDate_ = new stzDate('' + _oStartDate_[1] + "-" + _oStartDate_[2] + "-" + _oStartDate_[3])
	        but IsHashList(_oStartDate_) and HasKeys(_oStartDate_, [ :Year, :Month, :Day ])
	            _oStartDate_ = new stzDate('' + _oStartDate_[:Year] + "-" + _oStartDate_[:Month] + "-" + _oStartDate_[:Day])
	        ok
        ok

        if isList(_oEndDate_) and len(_oEndDate_) = 3
	        if IsListOfNumbers(_oEndDate_)
	            _oEndDate_ = new stzDate('' + _oEndDate_[1] + "-" + _oEndDate_[2] + "-" + _oEndDate_[3])
	        but IsHashList(_oEndDate_) and HasKeys(_oEndDate_, [ :Year, :Month, :Day ])
	            _oEndDate_ = new stzDate('' + _oEndDate_[:Year] + "-" + _oEndDate_[:Month] + "-" + _oEndDate_[:Day])
	        ok
        ok

        if isString(_oStartDate_)
            _oStartDate_ = new stzDate(_oStartDate_)
        ok
        if isString(_oEndDate_)
            _oEndDate_ = new stzDate(_oEndDate_)
        ok

        return This.IsAfter(_oStartDate_) and This.IsBefore(_oEndDate_)

    # Returns a new stzDate holding the same year, month and day, so the copy can change without the original.
    #
    #   returns    a new stzDate object
    #   see        SetComponents, Components
    def Copy()
        _oCopy_ = new stzDate([ @nYear, @nMonth, @nDay ])
        return _oCopy_

    #--- UTILITY METHODS ---#

    # Sets year, month and day from a list of three numbers, without any check.
    #
    #   aDate      a list [ year, month, day ]
    #   returns    nothing; the object changes in place
    #   note       SetComponentsQ answers the object so calls chain
    #   warning    a list of another length is ignored without an error; month 14 or day 99 are
    #              stored as given, and IsValid then answers FALSE
    #   see        Components, SetDate
    def SetComponents(aDate)
        if isList(aDate) and len(aDate) = 3
            @nYear = aDate[1]
            @nMonth = aDate[2]
            @nDay = aDate[3]
        ok

    def SetComponentsQ(aDate)
        This.SetComponents(aDate)
        return This

    # Returns the year, month and day as a list of three numbers.
    #
    #   returns    a list [ year, month, day ]
    #   note       [ 2026, 3, 15 ]
    #   see        SetComponents, Copy
    def Components()
        return [ @nYear, @nMonth, @nDay ]

    # TRUE if the stored year, month and day form a real calendar date.
    #
    #   returns    TRUE or FALSE
    #   note       leap years are honoured; a list or hash given to the constructor is the usual way
    #              to get FALSE
    #   see        Components, SetComponents
    def IsValid()
        if _IsValidDate(@nYear, @nMonth, @nDay)
            return 1
        else
            return 0
        ok

    # TRUE if the value is a stzDate, which every stzDate object answers, so other code can tell it from another value.
    #
    #   returns    TRUE
    #   see        IsValid
    def IsAStzDate()
        return 1

   # Splits a phrase such as 3 days into its number and its unit word, both lowercased.
   #
   #   _cExpression_   the phrase: a number, a space and a unit word
   #   returns         a list [ number, unit ], such as [ 3, "days" ], or an empty text when there
   #                   is no space
   #   note            3 Days gives [ 3, "days" ]
   #   warning         extra words after the unit are ignored; a double space between number and
   #                   unit gives an empty unit; a number that is not numeric raises R41
   #   see             ParseOperation
   func ExtractValueAndUnit(_cExpression_)
	    _cExpression_ = StzLower(trim(_cExpression_))
	    _acWords_ = @split(_cExpression_, " ")
	    if len(_acWords_) < 2

	        return ""
	    ok

	    _nValue_ = 0 + _acWords_[1]
	    _cUnit_ = _acWords_[2]

	    return [ _nValue_, _cUnit_ ]
