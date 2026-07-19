
#==========================================================#
# STZDATETIME CLASS - SOFTANZA LIBRARY - V0.9 (2019-2025)  #
# BY: MANSOUR AYOUNI - EMAIL: kalidianow@gmail.com         #
#==========================================================#

/*
HIERARCHICAL DATETIME FORMAT DESIGN
-----------------------------------

1. TIME SYSTEM (24h vs 12h)
   - Default: 24-hour (international standard)
   - 12-hour: Append "12h" suffix to format name OR use formats with AP marker

2. LOCALIZATION
   - ISO: Normalized, locale-independent (YYYY-MM-DD format)
   - Localized: Region-specific (DD/MM/YYYY or MM/DD/YYYY)

3. PRECISION
   - Minute: HH:mm
   - Second: HH:mm:ss
   - Millisecond: HH:mm:ss.zzz

4. VERBOSITY
   - Compact: Minimal characters (2024-03-15 14:30)
   - Standard: Common readable (15/03/2024 14:30:45)
   - Verbose: Full text (Friday, March 15, 2024 at 2:30:45 PM)

Format String Rules:
- h  = hour 0-23 (or 1-12 if AP present)
- hh = hour 00-23 (or 01-12 if AP present) with leading zero
- H  = same as h
- HH = same as hh
- AP = AM/PM marker (makes the format 12-hour automatically)
- ap = am/pm marker (lowercase)
*/


# Global datetime format configurations
$cDefaultDateTimeFormat = "yyyy-MM-dd HH:mm:ss"

$aDateTimeFormats = [

    # ===== ISO/NORMALIZED FORMATS (Locale-independent) =====
    # These formats are safe for data interchange and storage

    [ :ISO,           "yyyy-MM-dd HH:mm:ss" ],      # 2024-03-15 14:30:45
    [ :ISO24h,        "yyyy-MM-dd HH:mm:ss" ],      # 2024-03-15 14:30:45
    [ :ISOMinute,     "yyyy-MM-dd HH:mm" ],         # 2024-03-15 14:30
    [ :ISOWithMs,     "yyyy-MM-dd HH:mm:ss.zzz" ],  # 2024-03-15 14:30:45.123
    [ :ISO8601,       "yyyy-MM-ddTHH:mm:ss" ],      # 2024-03-15T14:30:45
    [ :ISO8601Ms,     "yyyy-MM-ddTHH:mm:ss.zzz" ],  # 2024-03-15T14:30:45.123

    [ :ISO12h,        "yyyy-MM-dd hh:mm:ss AP" ],   # 2024-03-15 02:30:45 PM
    [ :ISO12hMinute,  "yyyy-MM-dd hh:mm AP" ],      # 2024-03-15 02:30 PM

    # ===== COMPACT FORMATS =====
    # Short, efficient formats for logs and displays

    [ :Compact,       "yyyy-MM-dd HH:mm" ],         # 2024-03-15 14:30
    [ :Compact24h,    "yyyy-MM-dd HH:mm" ],         # 2024-03-15 14:30
    [ :CompactSec,    "yyyy-MM-dd HH:mm:ss" ],      # 2024-03-15 14:30:45
    [ :CompactMs,     "yyyy-MM-dd HH:mm:ss.zzz" ],  # 2024-03-15 14:30:45.123

    [ :Compact12h,    "yyyy-MM-dd hh:mm AP" ],      # 2024-03-15 02:30 PM
    [ :Compact12hSec, "yyyy-MM-dd hh:mm:ss AP" ],   # 2024-03-15 02:30:45 PM

    # ===== STANDARD FORMATS (Region-aware) =====
    # Common readable formats with slashes

    [ :Standard,      "dd/MM/yyyy HH:mm:ss" ],      # 15/03/2024 14:30:45
    [ :Standard24h,   "dd/MM/yyyy HH:mm:ss" ],      # 15/03/2024 14:30:45
    [ :StandardMinute,"dd/MM/yyyy HH:mm" ],         # 15/03/2024 14:30

    [ :Standard12h,   "dd/MM/yyyy hh:mm:ss AP" ],   # 15/03/2024 02:30:45 PM
    [ :Standard12hMin,"dd/MM/yyyy hh:mm AP" ],      # 15/03/2024 02:30 PM

    # ===== EUROPEAN FORMATS =====

    [ :European,      "dd/MM/yyyy HH:mm:ss" ],      # 15/03/2024 14:30:45
    [ :European24h,   "dd/MM/yyyy HH:mm:ss" ],      # 15/03/2024 14:30:45

    [ :European12h,   "dd/MM/yyyy hh:mm:ss AP" ],   # 15/03/2024 02:30:45 PM

    # ===== AMERICAN FORMATS =====

    [ :American,      "MM/dd/yyyy HH:mm:ss" ],      # 03/15/2024 14:30:45
    [ :American24h,   "MM/dd/yyyy HH:mm:ss" ],      # 03/15/2024 14:30:45

    [ :American12h,   "MM/dd/yyyy hh:mm:ss AP" ],   # 03/15/2024 02:30:45 PM

    # ===== VERBOSE FORMATS (Human-readable) =====
    # Full text representations

    [ :Verbose,       "dddd, MMMM d, yyyy HH:mm:ss" ],     # Friday, March 15, 2024 14:30:45
    [ :Verbose24h,    "dddd, MMMM d, yyyy HH:mm:ss" ],     # Friday, March 15, 2024 14:30:45
    [ :VerboseMinute, "dddd, MMMM d, yyyy HH:mm" ],        # Friday, March 15, 2024 14:30
    [ :LongDate,      "dddd, MMMM d, yyyy" ],              # Friday, March 15, 2024

    [ :Verbose12h,    "dddd, MMMM d, yyyy hh:mm:ss AP" ],  # Friday, March 15, 2024 02:30:45 PM
    [ :Verbose12hMin, "dddd, MMMM d, yyyy hh:mm AP" ],     # Friday, March 15, 2024 02:30 PM

    # ===== NAMED PATTERNS (handled specially in ToStringXT) =====
    # These are processed with custom logic, not direct format strings

    [ :Simple,        "dd/MM/yyyy hh:mm AP" ],      # 15/03/2024 2:30 PM (custom 12h logic)
    [ :Simple12h,     "dd/MM/yyyy hh:mm AP" ],      # 15/03/2024 2:30 PM (custom 12h logic)
    [ :Simple24h,     "dd/MM/yyyy HH:mm" ],         # 15/03/2024 14:30

    [ :Long,          "dddd, MMMM d, yyyy hh:mm:ss AP" ],  # Friday, March 15, 2024 2:30:45 PM
    [ :Long12h,       "dddd, MMMM d, yyyy hh:mm:ss AP" ],  # Friday, March 15, 2024 2:30:45 PM
    [ :Long24h,       "dddd, MMMM d, yyyy HH:mm:ss" ],     # Friday, March 15, 2024 14:30:45

    [ :Short,         "dd/MM hh:mm AP" ],           # 15/03 2:30 PM (custom logic)
    [ :Short12h,      "dd/MM hh:mm AP" ],           # 15/03 2:30 PM (custom logic)
    [ :Short24h,      "dd/MM HH:mm" ],              # 15/03 14:30

    [ :Medium,        "ddd, MMM d hh:mm AP" ],      # Fri, Mar 15 2:30 PM (custom logic)
    [ :Medium12h,     "ddd, MMM d hh:mm AP" ],      # Fri, Mar 15 2:30 PM (custom logic)
    [ :Medium24h,     "ddd, MMM d HH:mm" ],         # Fri, Mar 15 14:30

    # ===== SPECIAL FORMATS =====
    # Specific use cases

    [ :RFC2822,       "dd MMM yyyy HH:mm:ss" ],     # 15 Mar 2024 14:30:45
    [ :RFC282212h,    "dd MMM yyyy hh:mm:ss AP" ],  # 15 Mar 2024 02:30:45 PM
    [ :UnixLog,       "MMM d HH:mm:ss" ],           # Mar 15 14:30:45
    [ :ShortText,     "ddd MMM d HH:mm:ss yyyy" ],  # Fri Mar 15 14:30:45 2024
    [ :ShortText12h,  "ddd MMM d hh:mm:ss AP yyyy" ] # Fri Mar 15 02:30:45 PM 2024

]

#=================================================================
# CountingFrom API - Clear datetime epoch alternatives
#=================================================================

# Reference points (in milliseconds from Unix epoch)
aTimeOrigins = [
    :UnixEpoch = 0,                      # 1970-01-01
    :YearOne = -62135596800000,          # 1 CE
    :IslamicHijra = -42521587200000,  # 622 CE (Hijra)
    :USIndependence = -6106060800000,    # 1776-07-04
    :FrenchRevolution = -5594227200000,  # 1792-09-22
    :AtomicAge = -775929600000,          # 1945-07-16
    :SpaceAge = -394416000000,           # 1957-10-04 (Sputnik)
    :InternetAge = -315619200000,        # 1960-01-01
    :ModernComputing = -631152000000     # 1950-01-01
]

# Quick datetime creation functions
func StzDateTimeQ(pDateTime)
    return new stzDateTime(pDateTime)

func IsStzDateTime(p)
	if isObject(p) and classname(p) = "stzdatetime"
		return 1
	else
		return 0
	ok

	func @IsStzDateTime(p)
		return IsStzDateTime(p)

func StzNowDateTime()
    return StzDateTimeQ("").ToStringXT('yyyy-mm-dd hh:mm:ss')

    func NowDateTime()
        return StzNowDateTime()

    func StzNowXT()
        return StzNowDateTime()

    func NowXT()
        return StzNowDateTime()

func StzNowXTQ()
	return StzDateTimeQ("")

	func NowXTQ()
		return StzNowXTQ()

func StzIsDateTime(str)
    if not isString(str)
        return FALSE
    ok

	_Rx_ = new stzRegex(pat(:DateTime) )
	return _Rx_.MatchFirst(str)

    func IsDateTime(str)
        return StzIsDateTime(str)

    func StzIsValidDateTime(str)
        return StzIsDateTime(str)

    func IsValidDateTime(str)
        return StzIsDateTime(str)

func StzGetDateTimeFormat(cFormatNameOrString)
    if isString(cFormatNameOrString)
        _nDateTimeFormats1Len_ = len($aDateTimeFormats)
        for _iLoopDateTimeFormats1_ = 1 to _nDateTimeFormats1Len_
        	_aFormat_ = $aDateTimeFormats[_iLoopDateTimeFormats1_]
            if _aFormat_[1] = cFormatNameOrString
                return _aFormat_[2]
            ok
        next
        return cFormatNameOrString
    ok

    return $cDefaultDateTimeFormat

	func GetDateTimeFormat(cFormatNameOrString)
		return StzGetDateTimeFormat(cFormatNameOrString)

func StzIs12HourFormat(_cFormat_)
    _cActualFormat_ = StzGetDateTimeFormat(_cFormat_)

    if StzFindFirst("AP", StzUpper(_cActualFormat_)) > 0
        return TRUE
    ok

    if isString(_cFormat_) and StzRight(StzLower(_cFormat_), 3) = "12h"
        return TRUE
    ok

    return FALSE

	func Is12HourFormat(_cFormat_)
		return StzIs12HourFormat(_cFormat_)

func StzConvertTo12Hour(_nHour_)
    _nHour12_ = _nHour_ % 12
    if _nHour12_ = 0
        _nHour12_ = 12
    ok
    return _nHour12_

	func ConvertTo12Hour(_nHour_)
		return StzConvertTo12Hour(_nHour_)

func StzGetAmPmText(_nHour_)
    _oLocale_ = new stzLocale("")
    if _nHour_ >= 12
        return _oLocale_.pmText()
    else
        return _oLocale_.amText()
    ok

	func GetAmPmText(_nHour_)
		return StzGetAmPmText(_nHour_)

func _DateTimeFormatString(_nYear_, _nMonth_, _nDay_, _nHour_, _nMinute_, _nSecond_, _nMs_, _cFormat_)
    pHandle = StzEngineDateNew(_nYear_, _nMonth_, _nDay_)
    _cDayName_ = StzEngineDateDayName(pHandle)
    _cMonthName_ = StzEngineDateMonthName(pHandle)
    StzEngineDateFree(pHandle)

    _cResult_ = _cFormat_
    _cResult_ = StzReplace(_cResult_, "dddd", _cDayName_)
    _cResult_ = StzReplace(_cResult_, "ddd", StzLeft(_cDayName_, 3))
    _cResult_ = StzReplace(_cResult_, "dd", _PadLeft("" + _nDay_, 2, "0"))
    _cResult_ = StzReplace(_cResult_, "MMMM", _cMonthName_)
    _cResult_ = StzReplace(_cResult_, "MMM", StzLeft(_cMonthName_, 3))
    _cResult_ = StzReplace(_cResult_, "MM", _PadLeft("" + _nMonth_, 2, "0"))
    _cResult_ = StzReplace(_cResult_, "yyyy", "" + _nYear_)
    _nYY_ = _nYear_ % 100
    _cResult_ = StzReplace(_cResult_, "yy", _PadLeft("" + _nYY_, 2, "0"))
    _cResult_ = StzReplace(_cResult_, "zzz", _PadLeft("" + _nMs_, 3, "0"))
    _cResult_ = StzReplace(_cResult_, "HH", _PadLeft("" + _nHour_, 2, "0"))
    _cResult_ = StzReplace(_cResult_, "mm", _PadLeft("" + _nMinute_, 2, "0"))
    _cResult_ = StzReplace(_cResult_, "ss", _PadLeft("" + _nSecond_, 2, "0"))
    return _cResult_

func _SetComponentsFromUnixMs(_nMs_)
    _nSecs_ = floor(_nMs_ / 1000)
    _nRemMs_ = _nMs_ % 1000
    if _nRemMs_ < 0
        _nRemMs_ += 1000
        _nSecs_ -= 1
    ok
    pHandle = StzEngineDateTimeFromUnix(_nSecs_)
    _nY_ = StzEngineDateTimeYear(pHandle)
    _nMo_ = StzEngineDateTimeMonth(pHandle)
    _nD_ = StzEngineDateTimeDay(pHandle)
    _nH_ = StzEngineDateTimeHour(pHandle)
    _nMi_ = StzEngineDateTimeMinute(pHandle)
    _nS_ = StzEngineDateTimeSecond(pHandle)
    StzEngineDateTimeFree(pHandle)
    return [_nY_, _nMo_, _nD_, _nH_, _nMi_, _nS_, _nRemMs_]

func _ToUnixMs(_nYear_, _nMonth_, _nDay_, _nHour_, _nMinute_, _nSecond_, _nMs_)
    pHandle = StzEngineDateTimeNew(_nYear_, _nMonth_, _nDay_, _nHour_, _nMinute_, _nSecond_)
    _nUnix_ = StzEngineDateTimeToUnix(pHandle)
    StzEngineDateTimeFree(pHandle)
    return (_nUnix_ * 1000) + _nMs_


class stzDateTime from stzObject
    @nYear
    @nMonth
    @nDay
    @nHour
    @nMinute
    @nSecond
    @nMs
    @nTotalSeconds

	def init(pDateTime)
	    @nYear = 2000
	    @nMonth = 1
	    @nDay = 1
	    @nHour = 0
	    @nMinute = 0
	    @nSecond = 0
	    @nMs = 0

	    if IsNull(pDateTime) or pDateTime = ""
	        pHandle = StzEngineDateTimeNow()
	        @nYear = StzEngineDateTimeYear(pHandle)
	        @nMonth = StzEngineDateTimeMonth(pHandle)
	        @nDay = StzEngineDateTimeDay(pHandle)
	        @nHour = StzEngineDateTimeHour(pHandle)
	        @nMinute = StzEngineDateTimeMinute(pHandle)
	        @nSecond = StzEngineDateTimeSecond(pHandle)
	        @nMs = 0
	        StzEngineDateTimeFree(pHandle)

	    but isString(pDateTime)
	        if This.IsCountingFromString(pDateTime)
	            This.ParseCountingFrom(pDateTime)
	        else
	            if This.IsNaturalEpochString(pDateTime)
	                This.ParseNaturalEpoch(pDateTime)
	            else
	                This.ParseStringDateTime(pDateTime)
	            ok
	        ok

	    but isNumber(pDateTime)
	        _aComps_ = _SetComponentsFromUnixMs(pDateTime * 1000)
	        @nYear = _aComps_[1]
	        @nMonth = _aComps_[2]
	        @nDay = _aComps_[3]
	        @nHour = _aComps_[4]
	        @nMinute = _aComps_[5]
	        @nSecond = _aComps_[6]
	        @nMs = _aComps_[7]

	    but isList(pDateTime)
	        if len(pDateTime) = 2 and
	           isObject(pDateTime[1]) and isObject(pDateTime[2])
	            if pDateTime[1].IsAStzDate()
	                @nYear = pDateTime[1].Year()
	                @nMonth = pDateTime[1].Month()
	                @nDay = pDateTime[1].Day()
	            ok
	            if pDateTime[2].IsAStzTime()
	                @nHour = pDateTime[2].Hours()
	                @nMinute = pDateTime[2].Minutes()
	                @nSecond = pDateTime[2].Seconds()
	                @nMs = pDateTime[2].MilliSeconds()
	            ok

	        but IsHashList(pDateTime)
	            if HasKey(pDateTime, :CountingFrom)
	                This.SetCountingFrom(pDateTime[:CountingFrom], pDateTime[:Origin])

	            but HasKey(pDateTime, :CountingFromUnixStart)
	                This.SetCountingFrom(pDateTime[:CountingFromUnixStart], :UnixEpoch)

	            but HasKey(pDateTime, :CountingFromYearOne)
	                This.SetCountingFrom(pDateTime[:CountingFromYearOne], :YearOne)

	            but HasKey(pDateTime, :CountingFromIslamicHijra)
	                This.SetCountingFrom(pDateTime[:CountingFromIslamicHijra], :IslamicHijra)

	            but HasKey(pDateTime, :CountingFromUSIndependence)
	                This.SetCountingFrom(pDateTime[:CountingFromUSIndependence], :USIndependence)

	            but HasKey(pDateTime, :CountingFromSpaceAge)
	                This.SetCountingFrom(pDateTime[:CountingFromSpaceAge], :SpaceAge)

	            but HasKey(pDateTime, :CountingFromAtomicAge)
	                This.SetCountingFrom(pDateTime[:CountingFromAtomicAge], :AtomicAge)

	            but HasKey(pDateTime, :NaturalDuration)
	                _cOrigin_ = :UnixEpoch
	                if HasKey(pDateTime, :Origin)
	                    _cOrigin_ = pDateTime[:Origin]
	                ok
	                This.SetFromNaturalDuration(pDateTime[:NaturalDuration], _cOrigin_)

	            but HasKey(pDateTime, :FromEpochSeconds)
	                This._SetFromMsSinceEpoch(pDateTime[:FromEpochSeconds] * 1000)

	            but HasKey(pDateTime, :FromEpochMilliseconds)
	                This._SetFromMsSinceEpoch(pDateTime[:FromEpochMilliseconds])

	            but HasKey(pDateTime, :FromEpochMinutes)
	                This._SetFromMsSinceEpoch(pDateTime[:FromEpochMinutes] * 60 * 1000)

	            but HasKey(pDateTime, :FromEpochHours)
	                This._SetFromMsSinceEpoch(pDateTime[:FromEpochHours] * 3600 * 1000)

	            but HasKey(pDateTime, :FromEpochDays)
	                This._SetFromMsSinceEpoch(pDateTime[:FromEpochDays] * 86400 * 1000)

	            but HasKey(pDateTime, :FromEpochWeeks)
	                This._SetFromMsSinceEpoch(pDateTime[:FromEpochWeeks] * 604800 * 1000)

	            but HasKey(pDateTime, :FromEpochMonths)
	                This.SetFromEpochMonths(pDateTime[:FromEpochMonths])

	            but HasKey(pDateTime, :FromEpochYears)
	                This.SetFromEpochYears(pDateTime[:FromEpochYears])

	            but HasKey(pDateTime, :FromNaturalEpoch)
	                This.ParseNaturalEpoch(pDateTime[:FromNaturalEpoch])

	            but HasKey(pDateTime, :FromEpochDuration)
	                This.SetFromEpochDuration(pDateTime[:FromEpochDuration])

	            else
	                _nYear_ = 2000
	                _nMonth_ = 1
	                _nDay_ = 1
	                _nHour_ = 0
	                _nMinute_ = 0
	                _nSecond_ = 0

	                if HasKey(pDateTime, :Year)
	                    _nYear_ = 0+ pDateTime[:Year]
	                ok

	                if HasKey(pDateTime, :Month)
	                    _nMonth_ = 0+ pDateTime[:Month]
	                ok

	                if HasKey(pDateTime, :Day)
	                    _nDay_ = 0+ pDateTime[:Day]
	                ok

	                if HasKey(pDateTime, :Hour)
	                    _nHour_ = 0+ pDateTime[:Hour]
	                ok

	                if HasKey(pDateTime, :Minute)
	                    _nMinute_ = 0+ pDateTime[:Minute]
	                ok

	                if HasKey(pDateTime, :Second)
	                    _nSecond_ = 0+ pDateTime[:Second]
	                ok

	                @nYear = _nYear_
	                @nMonth = _nMonth_
	                @nDay = _nDay_
	                @nHour = _nHour_
	                @nMinute = _nMinute_
	                @nSecond = _nSecond_
	                @nMs = 0
	            ok
	        ok
	    ok

	    if not This.IsValid()
	        StzRaise("Invalid date/time provided!")
	    ok

    def _SetFromMsSinceEpoch(_nMs_)
        _aComps_ = _SetComponentsFromUnixMs(_nMs_)
        @nYear = _aComps_[1]
        @nMonth = _aComps_[2]
        @nDay = _aComps_[3]
        @nHour = _aComps_[4]
        @nMinute = _aComps_[5]
        @nSecond = _aComps_[6]
        @nMs = _aComps_[7]

    def _ToMsSinceEpoch()
        return _ToUnixMs(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs)

    def ParseStringDateTime(_cDateTime_)
        _cDateTime_ = trim(_cDateTime_)

        if StzFindFirst("T", _cDateTime_) > 0
            _aParts_ = split(_cDateTime_, "T")
            _cDatePart_ = _aParts_[1]
            _cTimePart_ = _aParts_[2]
            This._ParseDatePart(_cDatePart_)
            This._ParseTimePart(_cTimePart_)
            return
        ok

        _nSpacePos_ = StzFindFirst(" ", _cDateTime_)
        if _nSpacePos_ > 0
            _cDatePart_ = StzLeft(_cDateTime_, _nSpacePos_ - 1)
            _cRest_ = StzRight(_cDateTime_, StzLen(_cDateTime_) - _nSpacePos_)

            if This._LooksLikeDatePart(_cDatePart_)
                This._ParseDatePart(_cDatePart_)
                This._ParseTimePart(_cRest_)
                return
            ok
        ok

        if StzFindFirst("-", _cDateTime_) > 0 or StzFindFirst("/", _cDateTime_) > 0
            This._ParseDatePart(_cDateTime_)
            @nHour = 0
            @nMinute = 0
            @nSecond = 0
            @nMs = 0
            return
        ok

        StzRaise("Cannot parse date/time string: " + _cDateTime_)

    def _LooksLikeDatePart(cStr)
        return (StzFindFirst("-", cStr) > 0 or StzFindFirst("/", cStr) > 0)

    def _ParseDatePart(_cDatePart_)
        _aDateParts_ = []
        if StzFindFirst("/", _cDatePart_) > 0
            _aDateParts_ = split(_cDatePart_, "/")
        but StzFindFirst("-", _cDatePart_) > 0
            _aDateParts_ = split(_cDatePart_, "-")
        ok

        if len(_aDateParts_) != 3
            StzRaise("Cannot parse date part: " + _cDatePart_)
        ok

        if StzLen(_aDateParts_[1]) = 4
            @nYear = 0+ _aDateParts_[1]
            @nMonth = 0+ _aDateParts_[2]
            @nDay = 0+ _aDateParts_[3]
        else
            @nDay = 0+ _aDateParts_[1]
            @nMonth = 0+ _aDateParts_[2]
            @nYear = 0+ _aDateParts_[3]
        ok

    def _ParseTimePart(_cTimePart_)
        _cTimePart_ = trim(_cTimePart_)
        _bPM_ = FALSE
        _bAM_ = FALSE

        if StzUpper(StzRight(_cTimePart_, 2)) = "PM"
            _bPM_ = TRUE
            _cTimePart_ = trim(StzLeft(_cTimePart_, StzLen(_cTimePart_) - 2))
        but StzUpper(StzRight(_cTimePart_, 2)) = "AM"
            _bAM_ = TRUE
            _cTimePart_ = trim(StzLeft(_cTimePart_, StzLen(_cTimePart_) - 2))
        ok

        _aTimeParts_ = split(_cTimePart_, ":")
        if len(_aTimeParts_) < 2
            @nHour = 0
            @nMinute = 0
            @nSecond = 0
            @nMs = 0
            return
        ok

        @nHour = 0+ _aTimeParts_[1]
        @nMinute = 0+ _aTimeParts_[2]
        @nSecond = 0
        @nMs = 0

        if len(_aTimeParts_) >= 3
            _cSecPart_ = _aTimeParts_[3]
            if StzFindFirst(".", _cSecPart_) > 0
                _aSecParts_ = split(_cSecPart_, ".")
                @nSecond = 0+ _aSecParts_[1]
                if len(_aSecParts_) >= 2
                    @nMs = 0+ _aSecParts_[2]
                ok
            else
                @nSecond = 0+ _cSecPart_
            ok
        ok

        if _bPM_ and @nHour < 12
            @nHour = @nHour + 12
        ok
        if _bAM_ and @nHour = 12
            @nHour = 0
        ok

	def GuessDateTimeFormat(_cDateTime_)
	    if StzFindFirst("T", _cDateTime_) > 0
	        if StzFindFirst(".", _cDateTime_) > 0
	            return "yyyy-MM-ddTHH:mm:ss.zzz"
	        but StzFindFirst(":", _cDateTime_) > 0
	            _nColons_ = CountOccurrences(_cDateTime_, ":")
	            if _nColons_ = 2
	                return "yyyy-MM-ddTHH:mm:ss"
	            but _nColons_ = 1
	                return "yyyy-MM-ddTHH:mm"
	            ok
	        ok
	        return "yyyy-MM-dd"
	    ok

	    _cDateSep_ = ""
	    if StzFindFirst("/", _cDateTime_) > 0
	        _cDateSep_ = "/"
	    but StzFindFirst("-", _cDateTime_) > 0 and StzFindFirst(" ", _cDateTime_) = 0
	        return "yyyy-MM-dd"
	    but StzFindFirst("-", _cDateTime_) > 0
	        _cDateSep_ = "-"
	    ok

	    if _cDateSep_ = ""
	        return NULL
	    ok

	    _aParts_ = split(_cDateTime_, " ")
	    _cDatePart_ = _aParts_[1]
	    _cTimePart_ = ""
	    _cAMPM_ = ""

	    if len(_aParts_) >= 2
	        _cTimePart_ = _aParts_[2]
	        if len(_aParts_) >= 3
	            _cAMPM_ = " AP"
	        ok
	    ok

	    _aDateParts_ = split(_cDatePart_, _cDateSep_)
	    if len(_aDateParts_) != 3
	        return NULL
	    ok

	    _cDateFormat_ = ""
	    if StzLen(_aDateParts_[1]) = 4
	        _cDateFormat_ = "yyyy" + _cDateSep_ + "MM" + _cDateSep_ + "dd"
	    else
	        _cDateFormat_ = "dd" + _cDateSep_ + "MM" + _cDateSep_ + "yyyy"
	    ok

	    if _cTimePart_ != ""
	        _aTimeParts_ = split(_cTimePart_, ":")
	        _cTimeFormat_ = ""

	        if len(_aTimeParts_) >= 3
	            _cTimeFormat_ = "HH:mm:ss"
	        but len(_aTimeParts_) = 2
	            _cTimeFormat_ = "HH:mm"
	        ok

	        if StzFindFirst(".", _cTimePart_) > 0
	            _cTimeFormat_ = _cTimeFormat_ + ".zzz"
	        ok

	        return _cDateFormat_ + " " + _cTimeFormat_ + _cAMPM_
	    ok

	    return _cDateFormat_

	def TryManualParse(_cDateTime_)
	    _cDateTime_ = trim(_cDateTime_)

	    _nSpacePos_ = StzFindFirst(" ", _cDateTime_)
	    if _nSpacePos_ = 0
	        return This.TryManualDateParse(_cDateTime_)
	    ok

	    _cDatePart_ = StzLeft(_cDateTime_, _nSpacePos_ - 1)
	    _cRest_ = StzRight(_cDateTime_, StzLen(_cDateTime_) - _nSpacePos_)

	    _cTimePart_ = _cRest_
	    _bPM_ = FALSE
	    if StzUpper(StzRight(_cRest_, 2)) = "PM"
	        _bPM_ = TRUE
	        _cTimePart_ = trim(StzLeft(_cRest_, StzLen(_cRest_) - 2))
	    but StzUpper(StzRight(_cRest_, 2)) = "AM"
	        _cTimePart_ = trim(StzLeft(_cRest_, StzLen(_cRest_) - 2))
	    ok

	    _aDateParts_ = []
	    if StzFindFirst("/", _cDatePart_) > 0
	        _aDateParts_ = split(_cDatePart_, "/")
	    but StzFindFirst("-", _cDatePart_) > 0
	        _aDateParts_ = split(_cDatePart_, "-")
	    else
	        return FALSE
	    ok

	    if len(_aDateParts_) != 3
	        return FALSE
	    ok

	    _nYear_ = 0
	    _nMonth_ = 0
	    _nDay_ = 0

	    if StzLen(_aDateParts_[1]) = 4
	        _nYear_ = 0+ _aDateParts_[1]
	        _nMonth_ = 0+ _aDateParts_[2]
	        _nDay_ = 0+ _aDateParts_[3]
	    else
	        _nDay_ = 0+ _aDateParts_[1]
	        _nMonth_ = 0+ _aDateParts_[2]
	        _nYear_ = 0+ _aDateParts_[3]
	    ok

	    _aTimeParts_ = split(_cTimePart_, ":")
	    if len(_aTimeParts_) < 2
	        return FALSE
	    ok

	    _nHour_ = 0+ _aTimeParts_[1]
	    _nMinute_ = 0+ _aTimeParts_[2]
	    _nSecond_ = 0
	    _nMs_ = 0

	    if len(_aTimeParts_) >= 3
	        _cSecPart_ = _aTimeParts_[3]
	        if StzFindFirst(".", _cSecPart_) > 0
	            _aSecParts_ = split(_cSecPart_, ".")
	            _nSecond_ = 0+ _aSecParts_[1]
	            if len(_aSecParts_) >= 2
	                _nMs_ = 0+ _aSecParts_[2]
	            ok
	        else
	            _nSecond_ = 0+ _cSecPart_
	        ok
	    ok

	    if _bPM_ and _nHour_ < 12
	        _nHour_ = _nHour_ + 12
	    ok

	    try
	        @nYear = _nYear_
	        @nMonth = _nMonth_
	        @nDay = _nDay_
	        @nHour = _nHour_
	        @nMinute = _nMinute_
	        @nSecond = _nSecond_
	        @nMs = _nMs_

	        if This.IsValid()
	            return TRUE
	        ok
	    catch
	        return FALSE
	    done

	    return FALSE

	def TryManualDateParse(cDate)
	    _aDateParts_ = []

	    if StzFindFirst("/", cDate) > 0
	        _aDateParts_ = split(cDate, "/")
	    but StzFindFirst("-", cDate) > 0
	        _aDateParts_ = split(cDate, "-")
	    else
	        return FALSE
	    ok

	    if len(_aDateParts_) != 3
	        return FALSE
	    ok

	    _nYear_ = 0
	    _nMonth_ = 0
	    _nDay_ = 0

	    if StzLen(_aDateParts_[1]) = 4
	        _nYear_ = 0+ _aDateParts_[1]
	        _nMonth_ = 0+ _aDateParts_[2]
	        _nDay_ = 0+ _aDateParts_[3]
	    else
	        _nDay_ = 0+ _aDateParts_[1]
	        _nMonth_ = 0+ _aDateParts_[2]
	        _nYear_ = 0+ _aDateParts_[3]
	    ok

	    try
	        @nYear = _nYear_
	        @nMonth = _nMonth_
	        @nDay = _nDay_
	        @nHour = 0
	        @nMinute = 0
	        @nSecond = 0
	        @nMs = 0

	        return This.IsValid()
	    catch
	        return FALSE
	    done

	    return FALSE

	#--- EPOCH-BASED CREATION METHODS ---#

	def FromSecondsSinceEpoch(_nSeconds_)
	    return This.FromSecondsSinceEpochXT(_nSeconds_, :UnixEpoch)

	    def FromSecondsSinceEpochXT(_nSeconds_, _cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok

	        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
	        This._SetFromMsSinceEpoch(_nBaseMs_ + (_nSeconds_ * 1000))

	    def FromEpochSeconds(_nSeconds_)
	        return This.FromSecondsSinceEpoch(_nSeconds_)

	    def FromUnixTimestamp(_nSeconds_)
	        return This.FromSecondsSinceEpoch(_nSeconds_)

	def FromMillisecondsSinceEpoch(nMilliseconds)
	    return This.FromMillisecondsSinceEpochXT(nMilliseconds, :UnixEpoch)

	    def FromMillisecondsSinceEpochXT(nMilliseconds, _cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
	        This._SetFromMsSinceEpoch(_nBaseMs_ + nMilliseconds)

	    def FromEpochMilliseconds(nMilliseconds)
	        return This.FromMillisecondsSinceEpoch(nMilliseconds)

	def FromMinutesSinceEpoch(_nMinutes_)
	    return This.FromMinutesSinceEpochXT(_nMinutes_, :UnixEpoch)

	    def FromMinutesSinceEpochXT(_nMinutes_, _cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
	        This._SetFromMsSinceEpoch(_nBaseMs_ + (_nMinutes_ * 60 * 1000))

	    def FromEpochMinutes(_nMinutes_)
	        return This.FromMinutesSinceEpoch(_nMinutes_)

	def FromHoursSinceEpoch(_nHours_)
	    return This.FromHoursSinceEpochXT(_nHours_, :UnixEpoch)

	    def FromHoursSinceEpochXT(_nHours_, _cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
	        This._SetFromMsSinceEpoch(_nBaseMs_ + (_nHours_ * 3600 * 1000))

	    def FromEpochHours(_nHours_)
	        return This.FromHoursSinceEpoch(_nHours_)

	def FromDaysSinceEpoch(_nDays_)
	    return This.FromDaysSinceEpochXT(_nDays_, :UnixEpoch)

	    def FromDaysSinceEpochXT(_nDays_, _cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
	        This._SetFromMsSinceEpoch(_nBaseMs_ + (_nDays_ * 86400 * 1000))

	    def FromEpochDays(_nDays_)
	        return This.FromDaysSinceEpoch(_nDays_)

	def FromWeeksSinceEpoch(_nWeeks_)
	    return This.FromWeeksSinceEpochXT(_nWeeks_, :UnixEpoch)

	    def FromWeeksSinceEpochXT(_nWeeks_, _cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
	        This._SetFromMsSinceEpoch(_nBaseMs_ + (_nWeeks_ * 604800 * 1000))

	    def FromEpochWeeks(_nWeeks_)
	        return This.FromWeeksSinceEpoch(_nWeeks_)

	def FromMonthsSinceEpoch(_nMonths_)
	    return This.FromMonthsSinceEpochXT(_nMonths_, :UnixEpoch)

	    def FromMonthsSinceEpochXT(_nMonths_, _cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
	        _nYears_ = floor(_nMonths_ / 12)
	        _nRemainingMonths_ = _nMonths_ % 12

	        @nYear = 1970 + _nYears_
	        @nMonth = 1 + _nRemainingMonths_
	        @nDay = 1
	        @nHour = 0
	        @nMinute = 0
	        @nSecond = 0
	        @nMs = 0

	        if _nBaseMs_ != 0
	            _nCurrentMs_ = This._ToMsSinceEpoch()
	            This._SetFromMsSinceEpoch(_nCurrentMs_ + _nBaseMs_)
	        ok

	    def FromEpochMonths(_nMonths_)
	        return This.FromMonthsSinceEpoch(_nMonths_)

	def FromYearsSinceEpoch(_nYears_)
	    return This.FromYearsSinceEpochXT(_nYears_, :UnixEpoch)

	    def FromYearsSinceEpochXT(_nYears_, _cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nBaseMs_ = This.GetOriginBase(_cOrigin_)

	        @nYear = 1970 + _nYears_
	        @nMonth = 1
	        @nDay = 1
	        @nHour = 0
	        @nMinute = 0
	        @nSecond = 0
	        @nMs = 0

	        if _nBaseMs_ != 0
	            _nCurrentMs_ = This._ToMsSinceEpoch()
	            This._SetFromMsSinceEpoch(_nCurrentMs_ + _nBaseMs_)
	        ok

	    def FromEpochYears(_nYears_)
	        return This.FromYearsSinceEpoch(_nYears_)

	#--- NATURAL LANGUAGE EPOCH CREATION ---#

	def FromNaturalEpoch(_cNatural_)
	    return This.FromNaturalEpochXT(_cNatural_, :UnixEpoch)

	    def FromNaturalEpochXT(_cNatural_, _cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nDurationMs_ = This.ParseNaturalDuration(_cNatural_)
	        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
	        This._SetFromMsSinceEpoch(_nBaseMs_ + _nDurationMs_)

	    def FromNaturalSinceEpoch(_cNatural_)
	        return This.FromNaturalEpoch(_cNatural_)

	#--- COMBINED EPOCH CREATION WITH HASH ---#

	def FromEpochHash(aHash)
	    return This.FromEpochHashXT(aHash, :UnixEpoch)

	    def FromEpochHashXT(aHash, _cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nDurationMs_ = This.HashToMilliseconds(aHash)
	        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
	        This._SetFromMsSinceEpoch(_nBaseMs_ + _nDurationMs_)

	    def FromEpochDuration(aHash)
	        return This.FromEpochHash(aHash)

    #--- COMPONENT EXTRACTION ---#

    def Date()
        return _PadLeft("" + @nYear, 4, "0") + "-" + _PadLeft("" + @nMonth, 2, "0") + "-" + _PadLeft("" + @nDay, 2, "0")

    def DateQ()
        return new stzDate(This.Date())

	def Time()
	    return _PadLeft("" + @nHour, 2, "0") + ":" + _PadLeft("" + @nMinute, 2, "0") + ":" + _PadLeft("" + @nSecond, 2, "0")

    def TimeQ()
        return new stzTime(This.Time())

    #--- ARITHMETIC OPERATIONS ---#

    def AddDays(_nDays_)
        pHandle = StzEngineDateTimeNew(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond)
        pNew = StzEngineDateTimeAddDays(pHandle, _nDays_)
        @nYear = StzEngineDateTimeYear(pNew)
        @nMonth = StzEngineDateTimeMonth(pNew)
        @nDay = StzEngineDateTimeDay(pNew)
        @nHour = StzEngineDateTimeHour(pNew)
        @nMinute = StzEngineDateTimeMinute(pNew)
        @nSecond = StzEngineDateTimeSecond(pNew)
        StzEngineDateTimeFree(pHandle)
        StzEngineDateTimeFree(pNew)
        return This.ToString()

    def AddDaysQ(_nDays_)
        This.AddDays(_nDays_)
        return This

    def AddMonths(_nMonths_)
        _aResult_ = _DateAddMonths(@nYear, @nMonth, @nDay, _nMonths_)
        @nYear = _aResult_[1]
        @nMonth = _aResult_[2]
        @nDay = _aResult_[3]
        return This.ToString()

    def AddMonthsQ(_nMonths_)
        This.AddMonths(_nMonths_)
        return This

    def AddYears(_nYears_)
        _aResult_ = _DateAddYears(@nYear, @nMonth, @nDay, _nYears_)
        @nYear = _aResult_[1]
        @nMonth = _aResult_[2]
        @nDay = _aResult_[3]
        return This.ToString()

    def AddYearsQ(_nYears_)
        This.AddYears(_nYears_)
        return This

    def AddSeconds(_nSeconds_)
        pHandle = StzEngineDateTimeNew(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond)
        pNew = StzEngineDateTimeAddSeconds(pHandle, _nSeconds_)
        @nYear = StzEngineDateTimeYear(pNew)
        @nMonth = StzEngineDateTimeMonth(pNew)
        @nDay = StzEngineDateTimeDay(pNew)
        @nHour = StzEngineDateTimeHour(pNew)
        @nMinute = StzEngineDateTimeMinute(pNew)
        @nSecond = StzEngineDateTimeSecond(pNew)
        StzEngineDateTimeFree(pHandle)
        StzEngineDateTimeFree(pNew)
        return This.ToString()

    def AddSecondsQ(_nSeconds_)
        This.AddSeconds(_nSeconds_)
        return This

    def AddMinutes(_nMinutes_)
        return This.AddSeconds(_nMinutes_ * 60)

    def AddMinutesQ(_nMinutes_)
        This.AddMinutes(_nMinutes_)
        return This

    def AddHours(_nHours_)
        return This.AddSeconds(_nHours_ * 3600)

    def AddHoursQ(_nHours_)
        This.AddHours(_nHours_)
        return This

    def AddMilliseconds(nMsToAdd)
        _nTotalMs_ = @nMs + nMsToAdd
        _nExtraSecs_ = floor(_nTotalMs_ / 1000)
        @nMs = _nTotalMs_ % 1000
        if @nMs < 0
            @nMs += 1000
            _nExtraSecs_ -= 1
        ok
        if _nExtraSecs_ != 0
            This.AddSeconds(_nExtraSecs_)
        ok
        return This.ToStringXT("yyyy-MM-dd HH:mm:ss.zzz")

    def AddMillisecondsQ(_nMs_)
        This.AddMilliseconds(_nMs_)
        return This

    def SubtractDays(_nDays_)
        return This.AddDays(-_nDays_)

    def SubtractDaysQ(_nDays_)
        This.SubtractDays(_nDays_)
        return This

    def SubtractMonths(_nMonths_)
        return This.AddMonths(-_nMonths_)

    def SubtractMonthsQ(_nMonths_)
        This.SubtractMonths(_nMonths_)
        return This

    def SubtractYears(_nYears_)
        return This.AddYears(-_nYears_)

    def SubtractYearsQ(_nYears_)
        This.SubtractYears(_nYears_)
        return This

    def SubtractSeconds(_nSeconds_)
        return This.AddSeconds(-_nSeconds_)

    def SubtractSecondsQ(_nSeconds_)
        This.SubtractSeconds(_nSeconds_)
        return This

    def SubtractMilliSeconds(nMilliSeconds)
        return This.AddMilliseconds(-nMilliSeconds)

    def SubtractMilliSecondsQ(nMilliSeconds)
        This.SubtractMilliSeconds(nMilliSeconds)
        return This

    def SubtractHours(_nHours_)
	This.AddHours(-_nHours_)

	def SubtractHoursQ(_nHours_)
		This.AddHours(-_nHours_)
		return This

    def SubtractMinutes(_nMinutes_)
	This.AddMinutes(-_nMinutes_)

	def SubtractMinutesQ(_nMinutes_)
		This.AddMinutes(-_nMinutes_)
		return This

	def AddNatural(_cExpr_)
	    _cExpr_ = StzLower(trim(_cExpr_))

		_Rx_ = new stzRegex(pat(:DateTime))
	    if _Rx_.MatchFirst(_cExpr_)
	        return
	    ok

	    _aParts_ = split(_cExpr_, " ")

	    _i_ = 1
	    while _i_ <= len(_aParts_)
	        if isNumber(0+ _aParts_[_i_])
	            _nValue_ = 0+ _aParts_[_i_]
	            if _i_ < len(_aParts_)
	                _cUnit_ = StzLower(_aParts_[_i_+1])

	                if _cUnit_ = "day" or _cUnit_ = "days"
	                    This.AddDays(_nValue_)

	                but _cUnit_ = "month" or _cUnit_ = "months"
	                    This.AddMonths(_nValue_)

	                but _cUnit_ = "year" or _cUnit_ = "years"
	                    This.AddYears(_nValue_)

	                but _cUnit_ = "hour" or _cUnit_ = "hours"
	                    This.AddHours(_nValue_)

	                but _cUnit_ = "minute" or _cUnit_ = "minutes"
	                    This.AddMinutes(_nValue_)

	                but _cUnit_ = "second" or _cUnit_ = "seconds"
	                    This.AddSeconds(_nValue_)

	                but _cUnit_ = "millisecond" or _cUnit_ = "milliseconds"
	                    This.AddMilliseconds(_nValue_)
	                ok

	                _i_ += 2
	            else
	                _i_++
	            ok
	        else
	            _i_++
	        ok
	    end

	def SubtractNatural(_cExpr_)
	    _cExpr_ = StzLower(trim(_cExpr_))

	    if StzFindFirst("-", _cExpr_) > 0 or StzFindFirst(":", _cExpr_) > 0 or StzFindFirst("T", _cExpr_) > 0
	        return
	    ok

	    _aParts_ = split(_cExpr_, " ")

	    _i_ = 1
	    while _i_ <= len(_aParts_)
	        if isNumber(0+ _aParts_[_i_])
	            _nValue_ = 0+ _aParts_[_i_]
	            if _i_ < len(_aParts_)
	                _cUnit_ = StzLower(_aParts_[_i_+1])

	                if _cUnit_ = "day" or _cUnit_ = "days"
	                    This.SubtractDays(_nValue_)

	                but _cUnit_ = "month" or _cUnit_ = "months"
	                    This.SubtractMonths(_nValue_)

	                but _cUnit_ = "year" or _cUnit_ = "years"
	                    This.SubtractYears(_nValue_)

	                but _cUnit_ = "hour" or _cUnit_ = "hours"
	                    This.SubtractHours(_nValue_)

	                but _cUnit_ = "minute" or _cUnit_ = "minutes"
	                    This.SubtractMinutes(_nValue_)

	                but _cUnit_ = "second" or _cUnit_ = "seconds"
	                    This.SubtractSeconds(_nValue_)

	                but _cUnit_ = "millisecond" or _cUnit_ = "milliseconds"
	                    This.SubtractMilliSeconds(_nValue_)
	                ok

	                _i_ += 2
	            else
	                _i_++
	            ok
	        else
	            _i_++
	        ok
	    end

     #--- COMPARISON METHODS ---#

    def IsBefore(poOtherDateTime)
        if isString(poOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(poOtherDateTime)
			return This.IsBefore(_oOtherDateTime_)
        ok
        return This.SecsTo(poOtherDateTime) > 0

    def IsAfter(poOtherDateTime)
        if isString(poOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(poOtherDateTime)
			return This.IsAfter(_oOtherDateTime_)
        ok
        return This.SecsTo(poOtherDateTime) < 0

    def IsEqualTo(poOtherDateTime)
        if isString(poOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(poOtherDateTime)
			return This.IsEqualTo(_oOtherDateTime_)
        ok
        return This.SecsTo(poOtherDateTime) = 0

        def IsEqual(_oOtherDateTime_)
            return This.IsEqualTo(_oOtherDateTime_)

    def IsBetween(poStartDateTime, poEndDateTime)
        if CheckParams()
            if isList(poEndDateTime) and IsAndNamedParamList(poEndDateTime)
                _oEndDateTime_ = poEndDateTime[2]
		poEndDateTime = _oEndDateTime_
            ok
        ok

        if isString(poStartDateTime)
            _oStartDateTime_ = new stzDateTime(poStartDateTime)
	    return This.IsBetween(_oStartDateTime_, poEndDateTime)
        ok

        if isString(poEndDateTime)
            _oEndDateTime_ = new stzDateTime(poEndDateTime)
	    return This.ISBetween(poStartDateTime, _oEndDateTime_)
        ok

        return This.IsAfter(poStartDateTime) and This.IsBefore(poEndDateTime)

    def IsNow()
        pNow = StzEngineDateTimeNow()
        _nNowUnix_ = StzEngineDateTimeToUnix(pNow)
        StzEngineDateTimeFree(pNow)
        pThis = StzEngineDateTimeNew(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond)
        _nThisUnix_ = StzEngineDateTimeToUnix(pThis)
        StzEngineDateTimeFree(pThis)
        _nDiff_ = abs(_nThisUnix_ - _nNowUnix_)
        return _nDiff_ < 60

    def IsToday()
        return This.DateQ().IsToday()

    def IsTomorrow()
        return This.DateQ().IsTomorrow()

    def IsYesterday()
        return This.DateQ().IsYesterday()

    #--- UNIX TIMESTAMP ---#

    def ToUnixTimeStamp()
        pHandle = StzEngineDateTimeNew(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond)
        _nUnix_ = StzEngineDateTimeToUnix(pHandle)
        StzEngineDateTimeFree(pHandle)
        return _nUnix_

    def ToUnixTimeStampMs()
        return This._ToMsSinceEpoch()

	#--- EPOCH CONVERSIONS ---#

	def ToSecondsSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nCurrentMs_ = This._ToMsSinceEpoch()
	        _nOriginMs_ = This.GetOriginBase(_cOrigin_)
	        return floor((_nCurrentMs_ - _nOriginMs_) / 1000)

	def ToMillisecondsSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nCurrentMs_ = This._ToMsSinceEpoch()
	        _nOriginMs_ = This.GetOriginBase(_cOrigin_)
	        return _nCurrentMs_ - _nOriginMs_

	def ToMinutesSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToSecondsSinceEpochXT(_cOrigin_) / 60)

	def ToHoursSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToSecondsSinceEpochXT(_cOrigin_) / 3600)

	def ToDaysSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToSecondsSinceEpochXT(_cOrigin_) / 86400)

	def ToWeeksSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToSecondsSinceEpochXT(_cOrigin_) / 604800)

	def ToMonthsSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _aOriginComps_ = _SetComponentsFromUnixMs(This.GetOriginBase(_cOrigin_))
	        _nOriginYear_ = _aOriginComps_[1]
	        _nOriginMonth_ = _aOriginComps_[2]

	        _nYears_ = @nYear - _nOriginYear_
	        _nMonths_ = @nMonth - _nOriginMonth_

	        return (_nYears_ * 12) + _nMonths_

	def ToYearsSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _aOriginComps_ = _SetComponentsFromUnixMs(This.GetOriginBase(_cOrigin_))
	        _nOriginYear_ = _aOriginComps_[1]
	        _nOriginMonth_ = _aOriginComps_[2]
	        _nOriginDay_ = _aOriginComps_[3]

	        _nYears_ = @nYear - _nOriginYear_

	        if @nMonth < _nOriginMonth_ or
	           (@nMonth = _nOriginMonth_ and @nDay < _nOriginDay_)
	            _nYears_--
	        ok

	        return _nYears_

	def ToDecadesSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToYearsSinceEpochXT(_cOrigin_) / 10)

	def ToCenturiesSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToYearsSinceEpochXT(_cOrigin_) / 100)

    #--- TIME ZONE OPERATIONS ---#

    def ToUTCQ()
        _oNewDateTime_ = new stzDateTime("")
        _oNewDateTime_.SetComponents([@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs])
        return _oNewDateTime_

		def ToUTC()
			return This.ToUTCQ().Content()

    def ToLocalTimeQ()
        _oNewDateTime_ = new stzDateTime("")
        _oNewDateTime_.SetComponents([@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs])
        return _oNewDateTime_

		def ToLocalTime()
			return This.ToLocalTimeQ().Content()


	#--- TIME INFO

	def Year()
		return @nYear

		def YearN()
			return This.Year()

	def Month()
		return @nMonth

		def MonthN()
			return @nMonth

	def Day()
		return @nDay

		def DayN()
			return @nDay

	def Hours()
		return @nHour

		def HoursN()
			return This.Hours()

	def Minutes()
		return @nMinute

		def MinutesN()
			return This.Minutes()

	def Seconds()
		return @nSecond

		def SecondsN()
			return This.Seconds()

	def MilliSeconds()
		return @nMs

		def MilliSecondsN()
			return This.MilliSeconds()

		def MSeconds()
			return This.MilliSeconds()

		def MSecondsN()
			return This.MilliSeconds()


    #--- FORMATTING ---#

    def ToString()
        return This.ToStringXT("")

		def Content()
			return This.ToStringXT("")

		def DateTime()
			return This.ToStringXT("")

	def ToStringXT(_cFormat_)
	    if NOT isString(_cFormat_)
	        StzRaise("Incorrect param type! cFormat must be a string.")
	    ok

	    if _cFormat_ = ""
	        _cFormat_ = $cDefaultDateTimeFormat
	        if @nMs > 0
	            _cFormat_ = "yyyy-MM-dd HH:mm:ss.zzz"
	        ok
	    ok

	    _acNamedPatterns_ = [
	        "simple", "simple12h", "simple24h",
	        "long", "long12h", "long24h",
	        "short", "short12h", "short24h",
	        "medium", "medium12h", "medium24h",
	    ]

	    if StzFindFirst(_cFormat_, _acNamedPatterns_) > 0

	        if _cFormat_ = "simple" or _cFormat_ = "simple12h"
	            return This.ToSimple()

	        but _cFormat_ = "simple24h"
	            return _DateTimeFormatString(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs, "dd/MM/yyyy HH:mm")

	        but _cFormat_ = "long" or _cFormat_ = "long12h"
	            return This.ToLong()

	        but _cFormat_ = "long24h"
	            return _DateTimeFormatString(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs, "dddd, MMMM d, yyyy HH:mm:ss")

	        but _cFormat_ = "short" or _cFormat_ = "short12h"
	            _nHour12_ = StzConvertTo12Hour(@nHour)
	            _cAMPM_ = StzGetAmPmText(@nHour)
	            return _PadLeft("" + @nDay, 2, "0") + "/" + _PadLeft("" + @nMonth, 2, "0") + " " + _nHour12_ + ":" +
	                   _PadLeft("" + @nMinute, 2, "0") + " " + _cAMPM_

	        but _cFormat_ = "short24h"
	            return _PadLeft("" + @nDay, 2, "0") + "/" + _PadLeft("" + @nMonth, 2, "0") + " " + _PadLeft("" + @nHour, 2, "0") + ":" + _PadLeft("" + @nMinute, 2, "0")

	        but _cFormat_ = "medium" or _cFormat_ = "medium12h"
	            _nHour12_ = StzConvertTo12Hour(@nHour)
	            _cAMPM_ = StzGetAmPmText(@nHour)
	            pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
	            _cDayName_ = StzEngineDateDayName(pHandle)
	            _cMonthName_ = StzEngineDateMonthName(pHandle)
	            StzEngineDateFree(pHandle)
	            return StzLeft(_cDayName_, 3) + ", " + StzLeft(_cMonthName_, 3) + " " + @nDay + " " + _nHour12_ + ":" +
	                   _PadLeft("" + @nMinute, 2, "0") + " " + _cAMPM_

	        but _cFormat_ = "medium24h"
	            pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
	            _cDayName_ = StzEngineDateDayName(pHandle)
	            _cMonthName_ = StzEngineDateMonthName(pHandle)
	            StzEngineDateFree(pHandle)
	            return StzLeft(_cDayName_, 3) + ", " + StzLeft(_cMonthName_, 3) + " " + @nDay + " " + _PadLeft("" + @nHour, 2, "0") + ":" + _PadLeft("" + @nMinute, 2, "0")
	        ok

	    ok

	    _cQtFormat_ = StzGetDateTimeFormat(_cFormat_)

	    if StzFindFirst("AP", StzUpper(_cQtFormat_)) > 0
	        _cFormatWithout12h_ = StzReplace(_cQtFormat_, "AP", "")
	        _cFormatWithout12h_ = StzReplace(_cFormatWithout12h_, "ap", "")
	        _cFormatWithout12h_ = trim(_cFormatWithout12h_)

	        _nHour12_ = StzConvertTo12Hour(@nHour)

	        _cFormatFinal_ = StzReplace(_cFormatWithout12h_, "hh", _PadLeft("" + _nHour12_, 2, "0"))
	        if _cFormatFinal_ = _cFormatWithout12h_
	            _cFormatFinal_ = StzReplace(_cFormatWithout12h_, "h", "" + _nHour12_)
	        ok

	        _cResult_ = _DateTimeFormatString(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs, _cFormatFinal_)
	        _cAMPM_ = StzGetAmPmText(@nHour)

	        return _cResult_ + " " + _cAMPM_
	    else
	        return _DateTimeFormatString(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs, _cQtFormat_)
	    ok

	# Short formats

	def ToShort()
	    return This.ToStringXT(:Short12h)

		def ToShort12h()
		    return This.ToStringXT(:Short12h)

		def ToShortAP()
		    return This.ToStringXT(:Short12h)

		def ToShortAmPm()
		    return This.ToStringXT(:Short12h)

		def ToShortWithAP()
		    return This.ToStringXT(:Short12h)

		def ToShortWithAmPm()
		    return This.ToStringXT(:Short12h)

	def ToShort24h()
	    return This.ToStringXT(:Short24h)

		def ToShortWithoutAP()
		    return This.ToStringXT(:Short24h)

		def ToShortWithoutAmPm()
		    return This.ToStringXT(:Short24h)

	# Medium formats

	def ToMedium()
	    return This.ToStringXT(:Medium12h)

		def ToMedium12h()
		    return This.ToStringXT(:Medium12h)

		def ToMediumAP()
		    return This.ToStringXT(:Medium12h)

		def ToMediumAmPm()
		    return This.ToStringXT(:Medium12h)

		def ToMediumWithAP()
		    return This.ToStringXT(:Medium12h)

		def ToMediumWithAmPm()
		    return This.ToStringXT(:Medium12h)

	def ToMedium24h()
	    return This.ToStringXT(:Medium24h)

		def ToMediumWithoutAP()
		    return This.ToStringXT(:Medium24h)

		def ToMediumWithoutAmPm()
		    return This.ToStringXT(:Medium24h)

	#--

	def ToCompact()
	    return This.ToStringXT(:Compact12h)

		def ToCompact12h()
		    return This.ToStringXT(:Compact12h)

		def ToCompactAP()
		    return This.ToStringXT(:Compact12h)

		def ToCompactAmPm()
		    return This.ToStringXT(:Compact12h)

		def ToCompactWithAP()
		    return This.ToStringXT(:Compact12h)

		def ToCompactWithAmPm()
		    return This.ToStringXT(:Compact12h)

	def ToCompact24h()
	    return This.ToStringXT(:Compact24h)

		def ToCompactWithoutAP()
		    return This.ToStringXT(:Compact24h)

		def ToCompactWithoutAmPm()
		    return This.ToStringXT(:Compact24h)

	#--

	def ToStandard()
	    return This.ToStringXT(:Standard12h)

		def ToStandard12h()
		    return This.ToStringXT(:Standard12h)

		def ToStandardAP()
		    return This.ToStringXT(:Standard12h)

		def ToStandardAmPm()
		    return This.ToStringXT(:Standard12h)

		def ToStandardWithAP()
		    return This.ToStringXT(:Standard12h)

		def ToStandardWithAmPm()
		    return This.ToStringXT(:Standard12h)

	def ToStandard24h()
	    return This.ToStringXT(:Standard24h)

		def ToStandardWithoutAP()
		    return This.ToStringXT(:Standard24h)

		def ToStandardWithoutAmPm()
		    return This.ToStringXT(:Standard24h)

	#--

	def ToEuropean()
	    return This.ToStringXT(:European12h)

		def ToEuropean12h()
		    return This.ToStringXT(:European12h)

		def ToEuropeanAP()
		    return This.ToStringXT(:European12h)

		def ToEuropeanAmPm()
		    return This.ToStringXT(:European12h)

		def ToEuropeanWithAP()
		    return This.ToStringXT(:European12h)

		def ToEuropeanWithAmPm()
		    return This.ToStringXT(:European12h)

	def ToEuropean24h()
	    return This.ToStringXT(:European24h)

		def ToEuropeanWithoutAP()
		    return This.ToStringXT(:European24h)

		def ToEuropeanWithoutAmPm()
		    return This.ToStringXT(:European24h)

	#--

	def ToAmerican()
	    return This.ToStringXT(:American12h)

		def ToAmerican12h()
		    return This.ToStringXT(:American12h)

		def ToAmericanAP()
		    return This.ToStringXT(:American12h)

		def ToAmericanAmPm()
		    return This.ToStringXT(:American12h)

		def ToAmericanWithAP()
		    return This.ToStringXT(:American12h)

		def ToAmericanWithAmPm()
		    return This.ToStringXT(:American12h)

	def ToAmerican24h()
	    return This.ToStringXT(:American24h)

		def ToAmericanWithoutAP()
		    return This.ToStringXT(:American24h)

		def ToAmericanWithoutAmPm()
		    return This.ToStringXT(:American24h)

	#--

	def ToIso()
	    return This.ToStringXT(:Iso24h)

	def ToIso8601()
	    return This.ToStringXT(:ISO8601)

	def ToIsoWithMs()
	    return This.ToStringXT(:ISOWithMs)

	#--

	def ToVerbose()
	    return This.ToStringXT(:Verbose12h)

		def ToVerbose12h()
		    return This.ToStringXT(:Verbose12h)

		def ToVerboseAP()
		    return This.ToStringXT(:Verbose12h)

		def ToVerboseAmPm()
		    return This.ToStringXT(:Verbose12h)

		def ToVerboseWithAP()
		    return This.ToStringXT(:Verbose12h)

		def ToVerboseWithAmPm()
		    return This.ToStringXT(:Verbose12h)

	def ToVerbose24h()
	    return This.ToStringXT(:Verbose24h)

		def ToVerboseWithoutAP()
		    return This.ToStringXT(:Verbose24h)

		def ToVerboseWithoutAmPm()
		    return This.ToStringXT(:Verbose24h)

	#----

    def ToRFC2822()
        return This.ToStringXT("dd MMM yyyy HH:mm:ss")

    def ToTextDate()
        return This.ToStringXT("ddd MMM d HH:mm:ss yyyy")

	def ToSimple()
	    _oLocale_ = new stzLocale("")
	    _nHour12_ = @nHour % 12
	    if _nHour12_ = 0
	        _nHour12_ = 12
	    ok

	    _cResult_ = _PadLeft("" + @nDay, 2, "0") + "/" + _PadLeft("" + @nMonth, 2, "0") + "/" + "" + @nYear + " " + _nHour12_ + ":" +
	              _PadLeft("" + @nMinute, 2, "0")

	    if @nHour >= 12
	        _cResult_ += " " + _oLocale_.pmText()
	    else
	        _cResult_ += " " + _oLocale_.amText()
	    ok
	    return _cResult_


		def ToSimple12h()
			return This.ToSimple()

		def ToSimple24h()
		    return This.ToStringXT(:Simple24h)

	def ToLong()
	    _oLocale_ = new stzLocale("")
	    _nHour12_ = @nHour % 12
	    if _nHour12_ = 0
	        _nHour12_ = 12
	    ok

	    pHandle = StzEngineDateNew(@nYear, @nMonth, @nDay)
	    _cDayName_ = StzEngineDateDayName(pHandle)
	    _cMonthName_ = StzEngineDateMonthName(pHandle)
	    StzEngineDateFree(pHandle)

	    _cResult_ = _cDayName_ + ", " + _cMonthName_ + " " + @nDay + ", " + @nYear + " " + _nHour12_ + ":" +
	              _PadLeft("" + @nMinute, 2, "0") + ":" +
	              _PadLeft("" + @nSecond, 2, "0")

	    if @nHour >= 12
	        _cResult_ += " " + _oLocale_.pmText()
	    else
	        _cResult_ += " " + _oLocale_.amText()
	    ok
	    return _cResult_

		def ToLong12h()
			return This.ToLong()

		def ToLong24h()
		    return This.ToStringXT(:Long24h)

	def ToLongDate()
		return This.ToStringXT(:LongDate)

	def ToString12h()
	    _nHour12_ = StzConvertTo12Hour(@nHour)
	    _cAMPM_ = StzGetAmPmText(@nHour)

	    return _PadLeft("" + @nYear, 4, "0") + "-" + _PadLeft("" + @nMonth, 2, "0") + "-" + _PadLeft("" + @nDay, 2, "0") + " " + _nHour12_ + ":" +
	           _PadLeft("" + @nMinute, 2, "0") + ":" +
	           _PadLeft("" + @nSecond, 2, "0") + " " + _cAMPM_

    #--- HUMAN-READABLE ---#

    def ToHuman()
		_cDateHuman_ = This.DateQ().ToHuman()
        _cTimeHuman_ = This.TimeQ().ToHuman()

        return _cDateHuman_ + " at " + _cTimeHuman_

	def ToRelative()
	    _oNow_ = new stzDateTime("")

	    pThis = StzEngineDateTimeNew(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond)
	    _nThisUnix_ = StzEngineDateTimeToUnix(pThis)
	    StzEngineDateTimeFree(pThis)

	    pNow = StzEngineDateTimeNew(_oNow_.Year(), _oNow_.Month(), _oNow_.Day(), _oNow_.Hours(), _oNow_.Minutes(), _oNow_.Seconds())
	    _nNowUnix_ = StzEngineDateTimeToUnix(pNow)
	    StzEngineDateTimeFree(pNow)

	    _nSeconds_ = _nThisUnix_ - _nNowUnix_

	    _nAbsSecs_ = abs(_nSeconds_)

	    if _nAbsSecs_ < 60
	        return "just now"

	    but _nSeconds_ < 0
	        if _nAbsSecs_ < 3600
	            _nMinutes_ = floor(_nAbsSecs_ / 60.0 + 0.5)
	            return '' + _nMinutes_ + " minute" + Iff(_nMinutes_=1, "", "s") + " ago"

	        but _nAbsSecs_ < 86400
	            _nHours_ = floor(_nAbsSecs_ / 3600.0 + 0.5)
	            return '' + _nHours_ + " hour" + Iff(_nHours_=1, "", "s") + " ago"

	        but _nAbsSecs_ < 604800
	            _nDays_ = floor(_nAbsSecs_ / 86400.0 + 0.5)
	            return '' + _nDays_ + " day" + Iff(_nDays_=1, "", "s") + " ago"

	        but _nAbsSecs_ < 2592000
	            _nWeeks_ = floor(_nAbsSecs_ / 604800.0 + 0.5)
	            return '' + _nWeeks_ + " week" + Iff(_nWeeks_=1, "", "s") + " ago"

	        but _nAbsSecs_ < 31536000
	            _nMonths_ = floor(_nAbsSecs_ / 2592000.0 + 0.5)
	            return '' + _nMonths_ + " month" + Iff(_nMonths_=1, "", "s") + " ago"

	        else
	            _nYears_ = floor(_nAbsSecs_ / 31536000.0 + 0.5)
	            return '' + _nYears_ + " year" + Iff(_nYears_=1, "", "s") + " ago"
	        ok

	    else
	        if _nAbsSecs_ < 3600
	            _nMinutes_ = floor(_nAbsSecs_ / 60.0 + 0.5)
	            return "in " + _nMinutes_ + " minute" + Iff(_nMinutes_=1, "", "s")

	        but _nAbsSecs_ < 86400
	            _nHours_ = floor(_nAbsSecs_ / 3600.0 + 0.5)
	            return "in " + _nHours_ + " hour" + Iff(_nHours_=1, "", "s")

	        but _nAbsSecs_ < 604800
	            _nDays_ = floor(_nAbsSecs_ / 86400.0 + 0.5)
	            return "in " + _nDays_ + " day" + Iff(_nDays_=1, "", "s")

	        but _nAbsSecs_ < 2592000
	            _nWeeks_ = floor(_nAbsSecs_ / 604800.0 + 0.5)
	            return "in " + _nWeeks_ + " week" + Iff(_nWeeks_=1, "", "s")

	        but _nAbsSecs_ < 31536000
	            _nMonths_ = floor(_nAbsSecs_ / 2592000.0 + 0.5)
	            return "in " + _nMonths_ + " month" + Iff(_nMonths_=1, "", "s")

	        else
	            _nYears_ = floor(_nAbsSecs_ / 31536000.0 + 0.5)
	            return "in " + _nYears_ + " year" + Iff(_nYears_=1, "", "s")
	        ok
	    ok

    #--- UTILITY METHODS ---#

    def Copy()
        _oNewDateTime_ = new stzDateTime("")
        _oNewDateTime_.SetComponents([@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs])
        return _oNewDateTime_

    def SetComponents(aComponents)
        if isList(aComponents) and len(aComponents) >= 6
            @nYear = aComponents[1]
            @nMonth = aComponents[2]
            @nDay = aComponents[3]
            @nHour = aComponents[4]
            @nMinute = aComponents[5]
            @nSecond = aComponents[6]
            if len(aComponents) >= 7
                @nMs = aComponents[7]
            else
                @nMs = 0
            ok
        ok
        return This

    def SetComponentsQ(aComponents)
        This.SetComponents(aComponents)
        return This

    def Components()
        return [@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs]

    def IsValid()
        if @nMonth < 1 or @nMonth > 12
            return FALSE
        ok
        if @nDay < 1 or @nDay > _DaysInMonth(@nYear, @nMonth)
            return FALSE
        ok
        if @nHour < 0 or @nHour > 23
            return FALSE
        ok
        if @nMinute < 0 or @nMinute > 59
            return FALSE
        ok
        if @nSecond < 0 or @nSecond > 59
            return FALSE
        ok
        if @nMs < 0 or @nMs > 999
            return FALSE
        ok
        return TRUE

    def IsAStzDateTime()
        return TRUE

	def IsNaturalEpochString(cStr)
	    _cLower_ = StzLower(cStr)

	    if StzFindFirst("from epoch", _cLower_) > 0 or
	       StzFindFirst("since epoch", _cLower_) > 0
	        return TRUE
	    ok

	    return FALSE

	def ParseNaturalEpoch(_cNatural_)
	    _nTotalMilliseconds_ = 0

	    _cNatural_ = StzLower(_cNatural_)

	    _cNatural_ = StzReplace(_cNatural_, "from epoch", "")
	    _cNatural_ = StzReplace(_cNatural_, "since epoch", "")
	    _cNatural_ = trim(_cNatural_)

	    _aUnits_ = [
	        [:years, 31536000000],
	        [:year, 31536000000],
	        [:months, 2628000000],
	        [:month, 2628000000],
	        [:weeks, 604800000],
	        [:week, 604800000],
	        [:days, 86400000],
	        [:day, 86400000],
	        [:hours, 3600000],
	        [:hour, 3600000],
	        [:minutes, 60000],
	        [:minute, 60000],
	        [:mins, 60000],
	        [:min, 60000],
	        [:seconds, 1000],
	        [:second, 1000],
	        [:secs, 1000],
	        [:sec, 1000],
	        [:milliseconds, 1],
	        [:millisecond, 1],
	        [:msecs, 1],
	        [:msec, 1],
	        [:ms, 1]
	    ]

	    _nUnits2Len_ = len(_aUnits_)
	    for _iLoopUnits2_ = 1 to _nUnits2Len_
	    	_aUnit_ = _aUnits_[_iLoopUnits2_]
	        _cUnit_ = _aUnit_[1]
	        _nMultiplier_ = _aUnit_[2]

	        _cPattern_ = "(\d+\.?\d*)\s*" + _cUnit_

	        _nPos_ = StzFindFirst(_cUnit_, _cNatural_)
	        if _nPos_ > 0
	            _cBefore_ = StzLeft(_cNatural_, _nPos_ - 1)
	            _cBefore_ = trim(_cBefore_)

	            _aTokens_ = split(_cBefore_, " ")
	            if len(_aTokens_) > 0
	                _cNumber_ = _aTokens_[len(_aTokens_)]
	                _nValue_ = 0+ _cNumber_
	                _nTotalMilliseconds_ += (_nValue_ * _nMultiplier_)
	            ok
	        ok
	    next

	    This._SetFromMsSinceEpoch(_nTotalMilliseconds_)

	def SetFromEpochMonths(_nMonths_)
	    _nYears_ = floor(_nMonths_ / 12)
	    _nRemainingMonths_ = _nMonths_ % 12

	    @nYear = 1970 + _nYears_
	    @nMonth = 1 + _nRemainingMonths_
	    @nDay = 1
	    @nHour = 0
	    @nMinute = 0
	    @nSecond = 0
	    @nMs = 0

	def SetFromEpochYears(_nYears_)
	    @nYear = 1970 + _nYears_
	    @nMonth = 1
	    @nDay = 1
	    @nHour = 0
	    @nMinute = 0
	    @nSecond = 0
	    @nMs = 0

	def SetFromEpochDuration(aHash)
	    _nTotalMs_ = 0

	    if HasKey(aHash, :Years)
	        _nTotalMs_ += (aHash[:Years] * 31536000000)
	    ok

	    if HasKey(aHash, :Months)
	        _nTotalMs_ += (aHash[:Months] * 2628000000)
	    ok

	    if HasKey(aHash, :Weeks)
	        _nTotalMs_ += (aHash[:Weeks] * 604800000)
	    ok

	    if HasKey(aHash, :Days)
	        _nTotalMs_ += (aHash[:Days] * 86400000)
	    ok

	    if HasKey(aHash, :Hours)
	        _nTotalMs_ += (aHash[:Hours] * 3600000)
	    ok

	    if HasKey(aHash, :Minutes)
	        _nTotalMs_ += (aHash[:Minutes] * 60000)
	    ok

	    if HasKey(aHash, :Seconds)
	        _nTotalMs_ += (aHash[:Seconds] * 1000)
	    ok

	    if HasKey(aHash, :Milliseconds)
	        _nTotalMs_ += aHash[:Milliseconds]
	    ok

	    This._SetFromMsSinceEpoch(_nTotalMs_)

    #--- HELPER METHODS FOR COUNTINGFROM ---#

    def IsCountingFromString(cStr)
        _cLower_ = StzLower(cStr)
        return (StzFindFirst("counting from", _cLower_) > 0) or
		(StzFindFirst("starting from", _cLower_) > 0) or
		(StzFindFirst("since", _cLower_) > 0)

    def ParseCountingFrom(cStr)
        _cLower_ = StzLower(cStr)

        _nPos_ = StzFindFirst("counting from", _cLower_)
        if _nPos_ = 0
		_nPos_ = StzFindFirst("starting from", _cLower_)
	ok

	if _nPos_ = 0
		_nPos_ = StzFindFirst("since", _cLower_)
	ok

        if _nPos_ > 0
            _cDuration_ = StzLeft(cStr, _nPos_ - 1)
            _cOrigin_ = StzRight(cStr, StzLen(cStr) - _nPos_ - 12)
            _cOrigin_ = trim(_cOrigin_)

            _cOriginKey_ = This.MapOriginName(_cOrigin_)
            This.SetFromNaturalDuration(_cDuration_, _cOriginKey_)
        ok

    def MapOriginName(cName)
        _cLower_ = StzLower(trim(cName))

        if StzFindFirst("unix", _cLower_) > 0
            return :UnixEpoch

        but StzFindFirst("year one", _cLower_) > 0 or StzFindFirst("common era", _cLower_) > 0
            return :YearOne

        but StzFindFirst("islamic", _cLower_) > 0
            return :IslamicHijra

        but StzFindFirst("space age", _cLower_) > 0
            return :SpaceAge

        but StzFindFirst("atomic age", _cLower_) > 0
            return :AtomicAge

        but StzFindFirst("us independence", _cLower_) > 0
            return :USIndependence

        but StzFindFirst("french revolution", _cLower_) > 0
            return :FrenchRevolution

        but StzFindFirst("internet", _cLower_) > 0
            return :InternetAge

        else
            return :UnixEpoch
        ok

    def SetCountingFrom(_nValue_, _cOrigin_)
	if _cOrigin_ = ""
		_cOrigin_ = :UnixEpoch
	ok
        _nBaseMs_ = This.GetOriginBase(_cOrigin_)

        if isList(_nValue_) and IsHashList(_nValue_)
            _nDurationMs_ = This.HashToMilliseconds(_nValue_)
            This._SetFromMsSinceEpoch(_nBaseMs_ + _nDurationMs_)
        else
            This._SetFromMsSinceEpoch(_nBaseMs_ + (_nValue_ * 1000))
        ok

    def GetOriginBase(_cOrigin_)
        _nTimeOrigins1Len_ = len(aTimeOrigins)
        for _iLoopTimeOrigins1_ = 1 to _nTimeOrigins1Len_
        	_aOrigin_ = aTimeOrigins[_iLoopTimeOrigins1_]
            if _aOrigin_[1] = _cOrigin_
                return _aOrigin_[2]
            ok
        next
        return 0

    def SetFromNaturalDuration(_cDuration_, _cOrigin_)
	if _cOrigin_ = ""
		_cOrigin_ = :UnixEpoch
	ok
        _nDurationMs_ = This.ParseNaturalDuration(_cDuration_)
        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
        This._SetFromMsSinceEpoch(_nBaseMs_ + _nDurationMs_)

    def ParseNaturalDuration(_cDuration_)
        _nTotalMs_ = 0
        _cDuration_ = StzLower(trim(_cDuration_))

        _aUnits_ = [
            ["years", 31536000000],
            ["year", 31536000000],
            ["months", 2628000000],
            ["month", 2628000000],
            ["weeks", 604800000],
            ["week", 604800000],
            ["days", 86400000],
            ["day", 86400000],
            ["hours", 3600000],
            ["hour", 3600000],
            ["minutes", 60000],
            ["minute", 60000],
            ["seconds", 1000],
            ["second", 1000]
        ]

        _aTokens_ = split(_cDuration_, " ")

        _nUnits1Len_ = len(_aUnits_)
        for _iLoopUnits1_ = 1 to _nUnits1Len_
        	_aUnit_ = _aUnits_[_iLoopUnits1_]
            _cUnit_ = _aUnit_[1]
            _nMultiplier_ = _aUnit_[2]

            _nTokensLen_ = len(_aTokens_)
            for _i_ = 1 to _nTokensLen_
                if StzLower(_aTokens_[_i_]) = _cUnit_ and _i_ > 1
                    _nValue_ = 0+ _aTokens_[_i_-1]
                    _nTotalMs_ += (_nValue_ * _nMultiplier_)
                    exit
                ok
            next
        next

        return _nTotalMs_

    def HashToMilliseconds(aHash)
        _nMs_ = 0

        if HasKey(aHash, :Years)
            _nMs_ += (aHash[:Years] * 31536000000)
        ok

        if HasKey(aHash, :Months)
            _nMs_ += (aHash[:Months] * 2628000000)
        ok

        if HasKey(aHash, :Weeks)
            _nMs_ += (aHash[:Weeks] * 604800000)
        ok

        if HasKey(aHash, :Days)
            _nMs_ += (aHash[:Days] * 86400000)
        ok

        if Haskey(aHash, :Hours)
            _nMs_ += (aHash[:Hours] * 3600000)
        ok

        if HasKey(aHash, :Minutes)
            _nMs_ += (aHash[:Minutes] * 60000)
        ok

        if HasKey(aHash, :Seconds)
            _nMs_ += (aHash[:Seconds] * 1000)
        ok

        return _nMs_

    #--- DURATION CALCULATIONS TO A TARGET DATETIME ---#

	def DurationTo(pTarget, pcUnit)

	    if isList(pcUnit) and IsInNamedParamList(pcUnit)
		pcUnit = pcUnit[2]
		if NOT isString(pcUnit)
			StzRaise("Inocrrect param type! pcUnit must be a string.")
		ok
	    ok

	    _cUnit_ = StzLower(pcUnit)

	    if isString(_cUnit_) and StzLeft(_cUnit_, 2) = "in"
			_cUnit_ = StzRight(_cUnit_, StzLen(_cUnit_)-2)
	    ok

	    _cTarget_ = ""

	    if isObject(pTarget) and ring_classname(pTarget) = "stzdatetime"
		_oTarget_ = pTarget
	        _cTarget_ = pTarget.ToIso()
	    else
	        _oTarget_ = StzDateTimeQ(pTarget)
		_cTarget_ = _oTarget_.ToIso()
	    ok

	    _nThisMs_ = This._ToMsSinceEpoch()
	    _nTargetMs_ = _ToUnixMs(_oTarget_.Year(), _oTarget_.Month(), _oTarget_.Day(), _oTarget_.Hours(), _oTarget_.Minutes(), _oTarget_.Seconds(), _oTarget_.MilliSeconds())
	    _nMs_ = _nTargetMs_ - _nThisMs_

	    if _cUnit_ = NULL
	        _nSec_ = _nMs_ / 1000
	        _nMin_ = _nSec_ / 60
	        _nHour_ = _nMin_ / 60
	        _nDay_ = floor(_nMs_ / 86400000)
	        _nWeek_ = floor(_nDay_ / 7.0)

	        _oThisDate_ = This.DateQ()
	        _oTargetDate_ = _oTarget_.DateQ()
	        _nMonth_ = _oThisDate_.MonthsTo(_oTargetDate_)
	        _nYear_ = _oThisDate_.YearsTo(_oTargetDate_)
	        _nDecade_ = floor(_nYear_ / 10.0)
	        _nCentury_ = floor(_nYear_ / 100.0)

	        return [
	            :Milliseconds = _nMs_,
	            :Seconds = _nSec_,
	            :Minutes = _nMin_,
	            :Hours = _nHour_,
	            :Days = _nDay_,
	            :Weeks = _nWeek_,
	            :Months = _nMonth_,
	            :Years = _nYear_,
	            :Decades = _nDecade_,
	            :Centuries = _nCentury_
	        ]

	    else

	        switch _cUnit_
	        case :milliseconds
	            return _nMs_

	        case :seconds
	            return _nMs_ / 1000

	        case :minutes
	            return _nMs_ / 60000

	        case :hours
	            return _nMs_ / 3600000

	        case :days
	            return floor(_nMs_ / 86400000)

	        case :weeks
	            return floor(floor(_nMs_ / 86400000) / 7.0)

	        case :months
	            _oThisDate_ = This.DateQ()
	            _oTargetDate_ = _oTarget_.DateQ()
	            return _oThisDate_.MonthsTo(_oTargetDate_)

	        case :years
	            _oThisDate_ = This.DateQ()
	            _oTargetDate_ = _oTarget_.DateQ()
	            return _oThisDate_.YearsTo(_oTargetDate_)

	        case :decades
	            _oThisDate_ = This.DateQ()
	            _oTargetDate_ = _oTarget_.DateQ()
	            return floor(_oThisDate_.YearsTo(_oTargetDate_) / 10.0)

	        case :centuries
	            _oThisDate_ = This.DateQ()
	            _oTargetDate_ = _oTarget_.DateQ()
	            return floor(_oThisDate_.YearsTo(_oTargetDate_) / 100.0)

	        other
	            StzRaise("Unsupported unit: " + _cUnit_ + "!")
	        off
	    ok

	def DurationInMillisecondsTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Milliseconds)

	    def MillisecondsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Milliseconds)

	    def MSecsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Milliseconds)

	def DurationInSecondsTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Seconds)

	    def SecondsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Seconds)

	    def SecsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Seconds)

	def DurationInMinutesTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Minutes)

	    def MinutesTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Minutes)

	def DurationInHoursTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Hours)

	    def HoursTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :hours)

	def DurationInDaysTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Days)

	    def DaysTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Days)

	def DurationInWeeksTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Weeks)

	    def WeeksTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Weeks)

	def DurationInMonthsTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Months)

	    def MonthsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Months)

	def DurationInYearsTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Years)

	    def YearsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Years)

	def DurationInDecadesTo(cTo)
	    return This.DurationTo(pcUnit, :In = :Decades)

	    def DecadesTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Decades)

	def DurationInCenturiesTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Centuries)

	    def CenturiesTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Centuries)

        #--- DURATION CALCULATIONS FROM A GIVEN ORIGIN OR DATETIME ---#

    def DurationSince(pOrigin, pcUnit)

	if CheckParams()
		if isList(pcUnit) and IsInNamedParamList(pcUnit)
			pcUnit = pcUnit[2]
		ok

		if NOT isString(pcUnit)
			StzRaise("Incorrect param type! pcUnit must be a string.")
		ok
	ok

        _nMs_ = This.ToMillisecondsSinceEpochXT(pOrigin)

        if pcUnit = ""
            _nSec_ = This.ToSecondsSinceEpochXT(pOrigin)
            _nMin_ = This.ToMinutesSinceEpochXT(pOrigin)
            _nHour_ = This.ToHoursSinceEpochXT(pOrigin)
            _nDay_ = This.ToDaysSinceEpochXT(pOrigin)
            _nWeek_ = This.ToWeeksSinceEpochXT(pOrigin)
            _nMonth_ = This.ToMonthsSinceEpochXT(pOrigin)
            _nYear_ = This.ToYearsSinceEpochXT(pOrigin)
            _nDecade_ = This.ToDecadesSinceEpochXT(pOrigin)
            _nCentury_ = This.ToCenturiesSinceEpochXT(pOrigin)

            return [
                :Milliseconds = _nMs_,
                :Seconds = _nSec_,
                :Minutes = _nMin_,
                :Hours = _nHour_,
                :Days = _nDay_,
                :Weeks = _nWeek_,
                :Months = _nMonth_,
                :Years = _nYear_,
                :Decades = _nDecade_,
                :Centuries = _nCentury_
            ]

        else
            _cUnit_ = StzLower(pcUnit)

            switch _cUnit_
            case :milliseconds
                return _nMs_

            case :seconds
                return This.ToSecondsSinceEpochXT(pOrigin)

            case :minutes
                return This.ToMinutesSinceEpochXT(pOrigin)

            case :hours
                return This.ToHoursSinceEpochXT(pOrigin)

            case :days
                return This.ToDaysSinceEpochXT(pOrigin)

            case :weeks
                return This.ToWeeksSinceEpochXT(pOrigin)

            case :months
                return This.ToMonthsSinceEpochXT(pOrigin)

            case :years
                return This.ToYearsSinceEpochXT(pOrigin)

            case :decades
                return This.ToDecadesSinceEpochXT(pOrigin)

            case :centuries
                return This.ToCenturiesSinceEpochXT(pOrigin)

            other
                StzRaise("Unsupported unit: " + _cUnit_)
            off
        ok

    def DurationInMillisecondsFrom(pOrigin)
        return This.DurationSince(pOrigin, :In = :Milliseconds)

	def MillisecondsFrom(cFrom)
		return This.DurationSince(pOrigin, :In = :Milliseconds)

	    def DurationInMillisecondsSince(cFrom)
	        return This.DurationSince(pOrigin, :In = :Milliseconds)

	def MillisecondsSince(cFrom)
		return This.DurationSince(pOrigin, :In = :Milliseconds)

    def DurationInSecondsFrom(pOrigin)
        return This.DurationSince(pOrigin, :In = :Seconds)

	    def SecondsFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Seconds)

	    def DurationInSecondsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Seconds)

	    def SecondsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Seconds)

    def DurationInMinutesFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Minutes)

	    def MinutesFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Minutes)

	    def DurationInMinutesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Minutes)

	    def MinutesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Minutes)

    def DurationInHoursFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Hours)

	    def HoursFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Hours)

	    def DurationInHoursSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Hours)

	    def HoursSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Hours)

    def DurationInDaysFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Days)

	    def DaysFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Days)

	    def DurationInDaysSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Days)

	    def DaysSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Days)

    def DurationInWeeksFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Weeks)

	    def WeeksFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Weeks)

	    def DurationInWeeksSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Weeks)

	    def WeeksSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Weeks)

    def DurationInMonthsFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Months)

	    def MonthsFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Months)

	    def DurationInMonthsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Months)

	    def MonthsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Months)

    def DurationInYearsFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Years)

	    def YearsFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Years)

	    def DurationInYearsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Years)

	    def YearsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Years)


    def DurationInDecadesFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Decades)

	    def DecadesFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Decades)

	    def DurationInDecadesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Decades)

	    def DecadesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Decades)


    def DurationInCenturiesFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Centuries)

	    def CenturiesFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Centuries)

	    def DurationInCenturiesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Centuries)

	    def CenturiesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Centuries)

   #===

    def SetFromHash(aHash)
        _nYear_ = 2000
        _nMonth_ = 1
        _nDay_ = 1
        _nHour_ = 0
        _nMinute_ = 0
        _nSecond_ = 0

        if HasKey(aHash, :Year)
            _nYear_ = 0+ aHash[:Year]
        ok

        if HasKey(aHash, :Month)
            _nMonth_ = 0+ aHash[:Month]
        ok

        if HasKey(aHash, :Day)
            _nDay_ = 0+ aHash[:Day]
        ok

        if HasKey(aHash, :Hour)
            _nHour_ = 0+ aHash[:Hour]
        ok

        if HasKey(aHash, :Minute)
            _nMinute_ = 0+ aHash[:Minute]
        ok

        if HasKey(aHash, :Second)
            _nSecond_ = 0+ aHash[:Second]
        ok

        @nYear = _nYear_
        @nMonth = _nMonth_
        @nDay = _nDay_
        @nHour = _nHour_
        @nMinute = _nMinute_
        @nSecond = _nSecond_
        @nMs = 0

	# Operator overloading

	def operator(op, v)

	    if op = "+"
	        if isNumber(v)
	            This.AddSeconds(v)
	            return This

	        but isString(v)
	            _cLower_ = StzLower(trim(v))
	            _bHasDateTime_ = (StzFindFirst("-", v) > 0 and StzFindFirst(":", v) > 0)
	            _bHasUnits_ = (StzFindFirst(" day", _cLower_) > 0 or StzFindFirst(" month", _cLower_) > 0 or
	                        StzFindFirst(" year", _cLower_) > 0 or StzFindFirst(" hour", _cLower_) > 0 or
	                        StzFindFirst(" minute", _cLower_) > 0 or StzFindFirst(" second", _cLower_) > 0)

	            if not _bHasDateTime_ and _bHasUnits_
	                This.AddNatural(v)
	                return This
	            ok
	        ok

		but op = "-"

		    if isNumber(v)
		        This.SubtractSeconds(v)
		        return This

		    but isObject(v) and v.IsAStzDateTime()
		        return This.SecsTo(v)

		    but isString(v)

		        _cLower_ = StzLower(trim(v))
		        _bHasDateTime_ = (StzFindFirst("-", v) > 0 and StzFindFirst(":", v) > 0)
		        _bHasUnits_ = (StzFindFirst(" day", _cLower_) > 0 or StzFindFirst(" month", _cLower_) > 0 or
		                    StzFindFirst(" year", _cLower_) > 0 or StzFindFirst(" hour", _cLower_) > 0 or
		                    StzFindFirst(" minute", _cLower_) > 0 or StzFindFirst(" second", _cLower_) > 0)

		        if not _bHasDateTime_ and _bHasUnits_
		            This.SubtractNatural(v)
		            return This

		        else
		            _oOtherDateTime_ = new stzDateTime(v)
		            return This.SecsTo(_oOtherDateTime_)

		        ok
		    ok

	    but op = "<"
	        if isObject(v) and v.IsAStzDateTime()
	            return This.IsBefore(v)

	        but isString(v)
	            return This.IsBefore(new stzDateTime(v))

	        ok

	    but op = "<="

	        if isObject(v) and v.IsAStzDateTime()
	            return This.IsBefore(v) or This.IsEqualTo(v)

	        but isString(v)
	            _oTemp_ = new stzDateTime(v)
	            return This.IsBefore(_oTemp_) or This.IsEqualTo(_oTemp_)
	        ok

	    but op = ">"
	        if isObject(v) and v.IsAStzDateTime()
	            return This.IsAfter(v)

	        but isString(v)
	            return This.IsAfter(new stzDateTime(v))
	        ok

	    but op = ">="
	        if isObject(v) and v.IsAStzDateTime()
	            return This.IsAfter(v) or This.IsEqualTo(v)

	        but isString(v)
	            _oTemp_ = new stzDateTime(v)
	            return This.IsAfter(_oTemp_) or This.IsEqualTo(_oTemp_)
	        ok

	    but op = "="
	        if isObject(v) and v.IsAStzDateTime()
	            return This.IsEqualTo(v)

	        but isString(v)
	            return This.IsEqualTo(new stzDateTime(v))
	        ok
	    ok
