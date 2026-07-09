
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
    if _nYear_ % 400 = 0 return TRUE ok
    if _nYear_ % 100 = 0 return FALSE ok
    if _nYear_ % 4 = 0 return TRUE ok
    return FALSE

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
    if _nMonth_ < 1 or _nMonth_ > 12 return FALSE ok
    if _nDay_ < 1 or _nDay_ > _DaysInMonth(_nYear_, _nMonth_) return FALSE ok
    return TRUE

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
    if _cLanguage_ = NULL
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
    if _cLanguage_ = NULL
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
	if len(_acStzFcParts_) >= 1 and len(_acStzFcParts_[1]) >= 8 and StzMid(_acStzFcParts_[1], 5, 1) = "-"
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
	return Rx.Match(str)

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
	        if _aValueUnit_ != NULL
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

    def ParseStringDate(_cDate_)
        _cDate_ = trim(_cDate_)

        _aSeparators_ = ["/", "-", "."]
        _nSeparators1Len_ = len(_aSeparators_)
        for _iLoopSeparators1_ = 1 to _nSeparators1Len_
        	_cSep_ = _aSeparators_[_iLoopSeparators1_]
            if StzFindFirst(_cDate_, _cSep_) > 0
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

    def AddWeeks(_nWeeks_)
        This.AddDays(_nWeeks_ * 7)

	    def AddWeeksQ(_nWeeks_)
	        This.AddWeeks(_nWeeks_)
	        return This

    def AddMonths(_nMonths_)
        _aResult_ = _DateAddMonths(@nYear, @nMonth, @nDay, _nMonths_)
        @nYear = _aResult_[1]
        @nMonth = _aResult_[2]
        @nDay = _aResult_[3]

	    def AddMonthsQ(_nMonths_)
	        This.AddMonths(_nMonths_)
	        return This

    def AddYears(_nYears_)
        _aResult_ = _DateAddYears(@nYear, @nMonth, @nDay, _nYears_)
        @nYear = _aResult_[1]
        @nMonth = _aResult_[2]
        @nDay = _aResult_[3]

	    def AddYearsQ(_nYears_)
	        This.AddYears(_nYears_)
	        return This

    def SubtractDays(_nDays_)
        This.AddDays(-_nDays_)

	    def SubtractDaysQ(_nDays_)
	        This.SubtractDays(_nDays_)
	        return This

    def SubtractWeeks(_nWeeks_)
        This.AddDays(-_nWeeks_ * 7)

	    def SubtractWeeksQ(_nWeeks_)
	        This.SubtractWeeks(_nWeeks_)
	        return This

    def SubtractMonths(_nMonths_)
        This.AddMonths(-_nMonths_)

	    def SubtractMonthsQ(_nMonths_)
	        This.SubtractMonths(_nMonths_)
	        return This

    def SubtractYears(_nYears_)
        This.AddYears(-_nYears_)

	    def SubtractYearsQ(_nYears_)
	        This.SubtractYears(_nYears_)
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
    _nCurrentDay_ = This.DayOfWeek()
    _oCopy_ = This.Copy()

    if _nCurrentDay_ < 5
        _oCopy_.AddDays(1)
    else
        _oCopy_.AddDays(8 - _nCurrentDay_)
    ok
    return _oCopy_.ToString()

def PreviousWeekday()
    _nCurrentDay_ = This.DayOfWeek()
    _oCopy_ = This.Copy()

    if _nCurrentDay_ > 1
        _oCopy_.SubtractDays(1)
    else
        _oCopy_.SubtractDays(3)
    ok
    return _oCopy_.ToString()

def NextMonday()
    _nDaysToAdd_ = 8 - This.DayOfWeek()
    if _nDaysToAdd_ = 8
        _nDaysToAdd_ = 7
    ok

    _oCopy_ = This.Copy()
    _oCopy_.AddDays(_nDaysToAdd_)
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
    _nMid_ = ceil(_oCopy_.DaysInMonthN() / 2)
    _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), _nMid_ ])
    return _oCopy_.ToString()

    def MidMonthQ()
        _oCopy_ = This.Copy()
        _nMid_ = ceil(_oCopy_.DaysInMonthN() / 2)
        _oCopy_.SetDate([ _oCopy_.Year(), _oCopy_.MonthN(), _nMid_ ])
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
	    _aValueUnit_ = ExtractValueAndUnit(cOperation)

	    if _aValueUnit_ = NULL
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

    def WeeksTo(_oOtherDate_)
        return floor(This.DaysTo(_oOtherDate_) / 7)

	def WeeksToN(_oOtherDate_)
		return this.WeeksTo(_oOtherDate_)

	def WeeksToDate(_oOtherDate_)
		return this.WeeksTo(_oOtherDate_)

	def WeeksToDateN(_oOtherDate_)
		return this.WeeksTo(_oOtherDate_)

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


    def IsBefore(_oOtherDate_)
        return This.DaysTo(_oOtherDate_) > 0

    def IsAfter(_oOtherDate_)
        return This.DaysTo(_oOtherDate_) < 0

    def IsEqualTo(_oOtherDate_)
        return This.DaysTo(_oOtherDate_) = 0

		def IsEqual(_oOtherDate_)
			return This.DaysTo(_oOtherDate_) = 0

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

    def IsWeekend()
        _nDay_ = This.DayOfWeek()
        return (_nDay_ = 6 or _nDay_ = 7)

    def IsWeekday()
        return not This.IsWeekend()

    def IsToday()
        _aToday_ = _TodayYMD()
        if @nYear = _aToday_[1] and @nMonth = _aToday_[2] and @nDay = _aToday_[3]
			return 1
		else
			return 0
		ok

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

    def Age()
        _oToday_ = new stzDate("")
        _nYears_ = This.YearsTo(_oToday_)
        if _nYears_ < 0
            _nYears_ = -_nYears_
        ok
        return _nYears_

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

    def MonthInLanguage(_cLanguage_)
        return GetMonthNameXT(@nMonth, _cLanguage_)

    def MonthIn(_cLanguage_)
        return This.MonthInLanguage(_cLanguage_)

    def MonthShort()
        _cMonth_ = This.Month()
        return StzLeft(_cMonth_, 3)

    def Day()
        return GetDayName(This.DayOfWeek())

	def DayName()
		return This.Day()

    def DayN()
        return @nDay

   	 	def DayNumber()
        	return @nDay

    def DayInLanguage(_cLanguage_)
        return GetDayNameXT(This.DayOfWeek(), _cLanguage_)

    def DayIn(_cLanguage_)
        return DayInLanguage(_cLanguage_)

    def DayShort()
        _cDay_ = This.Day()
        return StzLeft(_cDay_, 3)

    def DayOfWeek()
        pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
        _nResult_ = StzEngineDateDayOfWeek(pHandle)
        StzEngineDateFree(pHandle)
        return _nResult_

    	def DayOfWeekN()
        	return This.DayOfWeek()

    def DayOfYear()
        pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
        _nResult_ = StzEngineDateDayOfYear(pHandle)
        StzEngineDateFree(pHandle)
        return _nResult_

    	def DayOfYearN()
       		 return This.DayOfYear()

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
        _nA_ = floor((14 - @nMonth) / 12)
        _nY_ = @nYear + 4800 - _nA_
        _nM_ = @nMonth + 12 * _nA_ - 3
        return @nDay + floor((153 * _nM_ + 2) / 5) + 365 * _nY_ + floor(_nY_ / 4) - floor(_nY_ / 100) + floor(_nY_ / 400) - 32045

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

    def Copy()
        _oCopy_ = new stzDate([ @nYear, @nMonth, @nDay ])
        return _oCopy_

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

   func ExtractValueAndUnit(_cExpression_)
	    _cExpression_ = StzLower(trim(_cExpression_))
	    _acWords_ = @split(_cExpression_, " ")
	    if len(_acWords_) < 2

	        return NULL
	    ok

	    _nValue_ = 0 + _acWords_[1]
	    _cUnit_ = _acWords_[2]

	    return [ _nValue_, _cUnit_ ]
