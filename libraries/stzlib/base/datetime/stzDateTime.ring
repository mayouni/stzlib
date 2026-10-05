
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
        return 0
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
        return 1
    ok

    if isString(_cFormat_) and StzRight(StzLower(_cFormat_), 3) = "12h"
        return 1
    ok

    return 0

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


# Holds one date and time, to the millisecond, and adds to it, compares it, measures distances from it and writes it in many formats.
#
# A stzDateTime is made of seven numbers (year, month, day, hour, minute, second, millisecond) that
# read as one instant with no time zone: ToUTC and ToLocalTime change nothing. Build it from a text
# (2026-03-15 14:30:00, 15/03/2026 2:30 PM, an ISO text with a T), from a number of seconds since
# 1970, from a hash of parts, or from an empty text for the current clock. The Add and Subtract
# methods move the object itself and answer the new text; the Q forms answer the object so calls
# chain. Compare with IsBefore, IsAfter, IsEqualTo and IsBetween; measure with the DurationTo family
# (against another datetime) and the DurationSince family (against a named origin such as :UnixEpoch
# or :YearOne). The To... methods write it as text: ToIso for storage, ToStandard and ToAmerican for
# display, ToHuman and ToRelative in words. Known gaps today, each carried as a warning on its
# method: instants before 1970 and every origin but :UnixEpoch give an invalid date, the Verbose
# family and ToLongDate print the letter d instead of the day, ParseNaturalEpoch counts plural units
# twice, and three Milliseconds methods raise.
#
#   receiver   o1 = new stzDateTime("2026-03-15 14:30:00")
#   example    ? o1.AddDays(3)
#              #--> 2026-03-18 14:30:00
#   see        stzDate, stzTime, stzDuration, stzCalendar
class stzDateTime from stzObject
    @nYear
    @nMonth
    @nDay
    @nHour
    @nMinute
    @nSecond
    @nMs
    @nTotalSeconds

	# Builds the datetime from text, a Unix timestamp in seconds, a hash of parts or a duration hash; an empty text means the current clock.
	#
	#   pDateTime   a date-time text such as 2026-03-15 14:30:00, a number of seconds since 1970, a
	#               hash such as [ :Year = 2026, :Month = 3 ], or a natural phrase such as 2 days
	#               since unix
	#   returns     nothing; the object is built
	#   note        a text with a 4-digit first part is read year-first, otherwise day-first; a
	#               missing time means 00:00:00; the current-clock form drops the milliseconds
	#   warning     raises Invalid date/time provided! when a part is out of range, when a number is
	#               negative, when the text is month-first such as 03/15/2026 (read as day-first),
	#               or for an origin before 1970; a [ stzDate, stzTime ] list raises R41 today;
	#               phrases such as 2 days from epoch count each plural unit twice
	#   see         stzDate, stzTime
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

    # Sets the object from a date or date-time text such as 2026-03-15T14:30:45.123 or 15/03/2026 2:30 PM; raises on text it cannot split.
    #
    #   _cDateTime_   the text to read, with - or / between the date parts and : between the time
    #                 parts
    #   returns       nothing; the object changes in place
    #   note          AM and PM after the time are honoured; a text with no - or / and no space
    #                 raises Cannot parse date/time string
    #   warning       does not check ranges: a month 13 is stored as given and IsValid then answers
    #                 FALSE; a fraction such as .5 is read as 5 milliseconds
    #   see           TryManualParse, GuessDateTimeFormat
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
        _bPM_ = 0
        _bAM_ = 0

        if StzUpper(StzRight(_cTimePart_, 2)) = "PM"
            _bPM_ = 1
            _cTimePart_ = trim(StzLeft(_cTimePart_, StzLen(_cTimePart_) - 2))
        but StzUpper(StzRight(_cTimePart_, 2)) = "AM"
            _bAM_ = 1
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

	# Returns the format pattern that fits a date-time text, such as dd/MM/yyyy HH:mm:ss, or an empty text when no date separator is found.
	#
	#   _cDateTime_   the date-time text to examine
	#   returns       a format pattern as text; empty text when none fits
	#   note          the pattern uses yyyy, MM, dd, HH, mm, ss, zzz and AP, and the object is not
	#                 changed
	#   warning       raises R3 today for an ISO text with a T and a time but no milliseconds, such
	#                 as 2026-03-15T14:30:45, because CountOccurrences exists nowhere
	#   see           ParseStringDateTime
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
	        return ""
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
	        return ""
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

	# Reads a date followed by a time (yyyy-MM-dd HH:mm:ss or dd/MM/yyyy hh:mm PM) into the object and answers whether it worked.
	#
	#   _cDateTime_   the date and time text to read
	#   returns       TRUE if the text was read and is a valid datetime, FALSE otherwise
	#   note          a failed read of text that does not look like a date leaves the object
	#                 unchanged
	#   warning       when the parts read but are out of range (month 13) it answers FALSE and still
	#                 leaves those values in the object; a text with no space is read as a date only
	#   see           TryManualDateParse, ParseStringDateTime
	def TryManualParse(_cDateTime_)
	    _cDateTime_ = trim(_cDateTime_)

	    _nSpacePos_ = StzFindFirst(" ", _cDateTime_)
	    if _nSpacePos_ = 0
	        return This.TryManualDateParse(_cDateTime_)
	    ok

	    _cDatePart_ = StzLeft(_cDateTime_, _nSpacePos_ - 1)
	    _cRest_ = StzRight(_cDateTime_, StzLen(_cDateTime_) - _nSpacePos_)

	    _cTimePart_ = _cRest_
	    _bPM_ = 0
	    if StzUpper(StzRight(_cRest_, 2)) = "PM"
	        _bPM_ = 1
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
	        return 0
	    ok

	    if len(_aDateParts_) != 3
	        return 0
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
	        return 0
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
	            return 1
	        ok
	    catch
	        return 0
	    done

	    return 0

	# Reads a date text (yyyy-MM-dd or dd/MM/yyyy) into the object with the time reset to 00:00:00, and answers whether it worked.
	#
	#   cDate      the date text to read
	#   returns    TRUE if the text was read and is a valid date, FALSE otherwise
	#   note       text that is not three parts separated by - or / leaves the object unchanged
	#   warning    when the parts read but are out of range (February 31) it answers FALSE and still
	#              leaves those values in the object
	#   see        TryManualParse
	def TryManualDateParse(cDate)
	    _aDateParts_ = []

	    if StzFindFirst("/", cDate) > 0
	        _aDateParts_ = split(cDate, "/")
	    but StzFindFirst("-", cDate) > 0
	        _aDateParts_ = split(cDate, "-")
	    else
	        return 0
	    ok

	    if len(_aDateParts_) != 3
	        return 0
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
	        return 0
	    done

	    return 0

	#--- EPOCH-BASED CREATION METHODS ---#

	# Sets the object to the instant n seconds after 1970-01-01 00:00:00, read as UTC.
	#
	#   _nSeconds_   the number of seconds since the Unix epoch
	#   returns      nothing; the object changes in place
	#   note         FromSecondsSinceEpochXT adds an origin name as second argument
	#   warning      a negative count leaves year 0, month 0, day 0, an invalid date, today
	#   see          FromMillisecondsSinceEpoch, ToUnixTimeStamp
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

	# Sets the object to the instant n milliseconds after 1970-01-01 00:00:00, keeping the milliseconds.
	#
	#   nMilliseconds   the number of milliseconds since the Unix epoch
	#   returns         nothing; the object changes in place
	#   note            FromMillisecondsSinceEpochXT adds an origin name as second argument
	#   warning         a negative count leaves year 0, month 0, day 0, an invalid date, today
	#   see             FromSecondsSinceEpoch
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

	# Sets the object to the instant n minutes after 1970-01-01 00:00:00.
	#
	#   _nMinutes_   the number of minutes since the Unix epoch
	#   returns      nothing; the object changes in place
	#   note         FromMinutesSinceEpochXT adds an origin name as second argument
	#   warning      a negative count leaves year 0, month 0, day 0, an invalid date, today
	#   see          FromHoursSinceEpoch
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

	# Sets the object to the instant n hours after 1970-01-01 00:00:00.
	#
	#   _nHours_   the number of hours since the Unix epoch
	#   returns    nothing; the object changes in place
	#   note       FromHoursSinceEpochXT adds an origin name as second argument
	#   warning    a negative count leaves year 0, month 0, day 0, an invalid date, today
	#   see        FromDaysSinceEpoch
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

	# Sets the object to midnight n days after 1970-01-01 (20000 gives 2024-10-04).
	#
	#   _nDays_    the number of days since the Unix epoch
	#   returns    nothing; the object changes in place
	#   note       FromDaysSinceEpochXT adds an origin name as second argument
	#   warning    a negative count leaves year 0, month 0, day 0, an invalid date, today
	#   see        FromWeeksSinceEpoch
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

	# Sets the object to midnight n weeks (7 days each) after 1970-01-01.
	#
	#   _nWeeks_   the number of weeks since the Unix epoch
	#   returns    nothing; the object changes in place
	#   note       FromWeeksSinceEpochXT adds an origin name as second argument
	#   warning    a negative count leaves year 0, month 0, day 0, an invalid date, today
	#   see        FromDaysSinceEpoch
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

	# Sets the object to the first day of the month n calendar months after January 1970, at 00:00:00.
	#
	#   _nMonths_   the number of months since January 1970
	#   returns     nothing; the object changes in place
	#   note        FromMonthsSinceEpochXT adds an origin name as second argument
	#   warning     a negative count leaves a month of 0 or less, an invalid date, and formatting a
	#               negative month (-3 months) stops the whole Ring process with a panic inside the
	#               engine
	#   see         FromYearsSinceEpoch, SetFromEpochMonths
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

	# Sets the object to January 1 at 00:00:00 of the year 1970 plus n.
	#
	#   _nYears_   the number of years since 1970
	#   returns    nothing; the object changes in place
	#   note       FromYearsSinceEpochXT adds an origin name as second argument
	#   see        FromMonthsSinceEpoch, SetFromEpochYears
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

	# Sets the object to 1970-01-01 plus a duration written in words, such as 2 days 3 hours.
	#
	#   _cNatural_   the duration in words: whole numbers each followed by years, months, weeks,
	#                days, hours, minutes or seconds
	#   returns      nothing; the object changes in place
	#   note         FromNaturalEpochXT adds an origin name as second argument
	#   warning      a word instead of a number (two days) raises R41; milliseconds are not read; a
	#                negative amount gives an invalid date; a year counts 365 days and a month 30.4
	#                days
	#   see          FromEpochHash, ParseNaturalDuration
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

	# Sets the object to 1970-01-01 plus a hash of durations such as [ :days = 3, :hours = 2 ].
	#
	#   aHash      a hash whose keys are years, months, weeks, days, hours, minutes or seconds
	#   returns    nothing; the object changes in place
	#   note       FromEpochHashXT adds an origin name as second argument
	#   warning    a :milliseconds key is ignored today; a negative total gives an invalid date
	#   see        FromNaturalEpoch, SetFromEpochDuration
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

    # Returns the date part as yyyy-MM-dd text.
    #
    #   returns    a string such as 2026-03-15
    #   note       the year is padded to 4 digits
    #   see        Time, DateQ
    def Date()
        return _PadLeft("" + @nYear, 4, "0") + "-" + _PadLeft("" + @nMonth, 2, "0") + "-" + _PadLeft("" + @nDay, 2, "0")

    def DateQ()
        return new stzDate(This.Date())

	# Returns the time part as HH:mm:ss text, without milliseconds.
	#
	#   returns    a string such as 14:30:00
	#   see        Date, TimeQ
	def Time()
	    return _PadLeft("" + @nHour, 2, "0") + ":" + _PadLeft("" + @nMinute, 2, "0") + ":" + _PadLeft("" + @nSecond, 2, "0")

    def TimeQ()
        return new stzTime(This.Time())

    #--- ARITHMETIC OPERATIONS ---#

    # Moves the datetime forward by n days, or back when n is negative, and answers the new datetime as text.
    #
    #   _nDays_    the number of days to add
    #   returns    the new datetime as text, yyyy-MM-dd HH:mm:ss
    #   note       changes the object in place; the time of day is kept
    #   see        SubtractDays, AddMonths
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

    # Moves the datetime forward by n calendar months, or back when n is negative, and answers the new datetime as text.
    #
    #   _nMonths_   the number of months to add
    #   returns     the new datetime as text, yyyy-MM-dd HH:mm:ss
    #   note        changes the object in place; the day is cut back to the last day of a shorter
    #               month, so 31 January plus 1 month is 28 February
    #   see         SubtractMonths, AddYears
    def AddMonths(_nMonths_)
        _aResult_ = _DateAddMonths(@nYear, @nMonth, @nDay, _nMonths_)
        @nYear = _aResult_[1]
        @nMonth = _aResult_[2]
        @nDay = _aResult_[3]
        return This.ToString()

    def AddMonthsQ(_nMonths_)
        This.AddMonths(_nMonths_)
        return This

    # Moves the datetime forward by n calendar years, or back when n is negative, and answers the new datetime as text.
    #
    #   _nYears_   the number of years to add
    #   returns    the new datetime as text, yyyy-MM-dd HH:mm:ss
    #   note       changes the object in place; 29 February moves to 28 February in a common year
    #   see        SubtractYears, AddMonths
    def AddYears(_nYears_)
        _aResult_ = _DateAddYears(@nYear, @nMonth, @nDay, _nYears_)
        @nYear = _aResult_[1]
        @nMonth = _aResult_[2]
        @nDay = _aResult_[3]
        return This.ToString()

    def AddYearsQ(_nYears_)
        This.AddYears(_nYears_)
        return This

    # Moves the datetime forward by n seconds, or back when n is negative, and answers the new datetime as text.
    #
    #   _nSeconds_   the number of seconds to add
    #   returns      the new datetime as text, yyyy-MM-dd HH:mm:ss
    #   note         changes the object in place; the milliseconds are kept
    #   see          AddMilliseconds, SubtractSeconds
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

    # Moves the datetime forward by n minutes, or back when n is negative, and answers the new datetime as text.
    #
    #   _nMinutes_   the number of minutes to add
    #   returns      the new datetime as text, yyyy-MM-dd HH:mm:ss
    #   note         changes the object in place
    #   see          SubtractMinutes, AddHours
    def AddMinutes(_nMinutes_)
        return This.AddSeconds(_nMinutes_ * 60)

    def AddMinutesQ(_nMinutes_)
        This.AddMinutes(_nMinutes_)
        return This

    # Moves the datetime forward by n hours, or back when n is negative, and answers the new datetime as text.
    #
    #   _nHours_   the number of hours to add
    #   returns    the new datetime as text, yyyy-MM-dd HH:mm:ss
    #   note       changes the object in place
    #   see        SubtractHours, AddDays
    def AddHours(_nHours_)
        return This.AddSeconds(_nHours_ * 3600)

    def AddHoursQ(_nHours_)
        This.AddHours(_nHours_)
        return This

    # Moves the datetime forward by n milliseconds, carrying into seconds, and answers the new datetime as text with its milliseconds.
    #
    #   nMsToAdd   the number of milliseconds to add
    #   returns    the new datetime as text, yyyy-MM-dd HH:mm:ss.zzz
    #   note       changes the object in place
    #   see        SubtractMilliSeconds, AddSeconds
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

    # Moves the datetime back by n days and answers the new datetime as text.
    #
    #   _nDays_    the number of days to subtract
    #   returns    the new datetime as text, yyyy-MM-dd HH:mm:ss
    #   note       changes the object in place
    #   see        AddDays
    def SubtractDays(_nDays_)
        return This.AddDays(-_nDays_)

    def SubtractDaysQ(_nDays_)
        This.SubtractDays(_nDays_)
        return This

    # Moves the datetime back by n calendar months and answers the new datetime as text.
    #
    #   _nMonths_   the number of months to subtract
    #   returns     the new datetime as text, yyyy-MM-dd HH:mm:ss
    #   note        changes the object in place; the day is cut back to the last day of a shorter
    #               month
    #   see         AddMonths
    def SubtractMonths(_nMonths_)
        return This.AddMonths(-_nMonths_)

    def SubtractMonthsQ(_nMonths_)
        This.SubtractMonths(_nMonths_)
        return This

    # Moves the datetime back by n calendar years and answers the new datetime as text.
    #
    #   _nYears_   the number of years to subtract
    #   returns    the new datetime as text, yyyy-MM-dd HH:mm:ss
    #   note       changes the object in place
    #   see        AddYears
    def SubtractYears(_nYears_)
        return This.AddYears(-_nYears_)

    def SubtractYearsQ(_nYears_)
        This.SubtractYears(_nYears_)
        return This

    # Moves the datetime back by n seconds and answers the new datetime as text.
    #
    #   _nSeconds_   the number of seconds to subtract
    #   returns      the new datetime as text, yyyy-MM-dd HH:mm:ss
    #   note         changes the object in place
    #   see          AddSeconds
    def SubtractSeconds(_nSeconds_)
        return This.AddSeconds(-_nSeconds_)

    def SubtractSecondsQ(_nSeconds_)
        This.SubtractSeconds(_nSeconds_)
        return This

    # Moves the datetime back by n milliseconds and answers the new datetime as text with its milliseconds.
    #
    #   nMilliSeconds   the number of milliseconds to subtract
    #   returns         the new datetime as text, yyyy-MM-dd HH:mm:ss.zzz
    #   note            changes the object in place
    #   see             AddMilliseconds
    def SubtractMilliSeconds(nMilliSeconds)
        return This.AddMilliseconds(-nMilliSeconds)

    def SubtractMilliSecondsQ(nMilliSeconds)
        This.SubtractMilliSeconds(nMilliSeconds)
        return This

    # Moves the datetime back by n hours, changing the object in place.
    #
    #   _nHours_   the number of hours to subtract
    #   returns    nothing; the object changes in place
    #   note       unlike the other Subtract methods it answers nothing
    #   see        AddHours, SubtractMinutes
    def SubtractHours(_nHours_)
	This.AddHours(-_nHours_)

	def SubtractHoursQ(_nHours_)
		This.AddHours(-_nHours_)
		return This

    # Moves the datetime back by n minutes, changing the object in place.
    #
    #   _nMinutes_   the number of minutes to subtract
    #   returns      nothing; the object changes in place
    #   note         unlike the other Subtract methods it answers nothing
    #   see          AddMinutes, SubtractHours
    def SubtractMinutes(_nMinutes_)
	This.AddMinutes(-_nMinutes_)

	def SubtractMinutesQ(_nMinutes_)
		This.AddMinutes(-_nMinutes_)
		return This

	# Adds a duration written in words, such as 2 hours 30 minutes, to the datetime in place.
	#
	#   _cExpr_    the duration in words: numbers each followed by day, month, year, hour, minute,
	#              second or millisecond (singular or plural)
	#   returns    nothing; the object changes in place
	#   note       the words are read in order and each amount is added with the matching Add method
	#   warning    weeks are silently ignored; a text that looks like a datetime does nothing
	#   see        SubtractNatural, AddDays
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

	# Subtracts a duration written in words, such as 1 year 2 months, from the datetime in place.
	#
	#   _cExpr_    the duration in words: numbers each followed by day, month, year, hour, minute,
	#              second or millisecond (singular or plural)
	#   returns    nothing; the object changes in place
	#   note       the words are read in order and each amount is taken off with the matching
	#              Subtract method
	#   warning    weeks are silently ignored; a text that contains - or : does nothing, so a
	#              negative amount has no effect
	#   see        AddNatural, SubtractDays
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

    # TRUE if the datetime is strictly earlier than another one, compared to the millisecond.
    #
    #   poOtherDateTime   the other datetime, as a stzDateTime or as a date-time text
    #   returns           TRUE or FALSE
    #   note              equal datetimes answer FALSE
    #   see               IsAfter, IsBetween
    def IsBefore(poOtherDateTime)
        if isString(poOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(poOtherDateTime)
			return This.IsBefore(_oOtherDateTime_)
        ok
        return This.SecsTo(poOtherDateTime) > 0

    # TRUE if the datetime is strictly later than another one, compared to the millisecond.
    #
    #   poOtherDateTime   the other datetime, as a stzDateTime or as a date-time text
    #   returns           TRUE or FALSE
    #   note              equal datetimes answer FALSE
    #   see               IsBefore, IsBetween
    def IsAfter(poOtherDateTime)
        if isString(poOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(poOtherDateTime)
			return This.IsAfter(_oOtherDateTime_)
        ok
        return This.SecsTo(poOtherDateTime) < 0

    # TRUE if both datetimes are the same instant, compared to the millisecond.
    #
    #   poOtherDateTime   the other datetime, as a stzDateTime or as a date-time text
    #   returns           TRUE or FALSE
    #   note              the object is not changed
    #   see               IsBefore, IsAfter
    def IsEqualTo(poOtherDateTime)
        if isString(poOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(poOtherDateTime)
			return This.IsEqualTo(_oOtherDateTime_)
        ok
        return This.SecsTo(poOtherDateTime) = 0

        def IsEqual(_oOtherDateTime_)
            return This.IsEqualTo(_oOtherDateTime_)

    # TRUE if the datetime lies strictly after the start and strictly before the end.
    #
    #   poStartDateTime   the earlier bound, as a stzDateTime or a date-time text
    #   poEndDateTime     the later bound, in the same forms, or written :And = bound
    #   returns           TRUE or FALSE
    #   note              both bounds are excluded, and an end earlier than the start answers FALSE
    #   see               IsBefore, IsAfter
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

    # TRUE if the datetime lies within 60 seconds, before or after, of the system clock.
    #
    #   returns    TRUE or FALSE
    #   note       depends on the clock when it is called
    #   see        IsToday
    def IsNow()
        pNow = StzEngineDateTimeNow()
        _nNowUnix_ = StzEngineDateTimeToUnix(pNow)
        StzEngineDateTimeFree(pNow)
        pThis = StzEngineDateTimeNew(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond)
        _nThisUnix_ = StzEngineDateTimeToUnix(pThis)
        StzEngineDateTimeFree(pThis)
        _nDiff_ = abs(_nThisUnix_ - _nNowUnix_)
        return _nDiff_ < 60

    # TRUE if the date part is today's date by the system clock.
    #
    #   returns    TRUE or FALSE
    #   note       depends on the clock when it is called
    #   see        IsTomorrow, IsYesterday
    def IsToday()
        return This.DateQ().IsToday()

    # TRUE if the date part is the day after today by the system clock.
    #
    #   returns    TRUE or FALSE
    #   note       depends on the clock when it is called
    #   see        IsToday
    def IsTomorrow()
        return This.DateQ().IsTomorrow()

    # TRUE if the date part is the day before today by the system clock.
    #
    #   returns    TRUE or FALSE
    #   note       depends on the clock when it is called
    #   see        IsToday
    def IsYesterday()
        return This.DateQ().IsYesterday()

    #--- UNIX TIMESTAMP ---#

    # Returns the whole seconds from 1970-01-01 00:00:00 to the datetime, reading its fields as UTC.
    #
    #   returns    a number of seconds
    #   note       no time zone is applied and the milliseconds are dropped
    #   see        ToSecondsSinceEpochXT, FromSecondsSinceEpoch
    def ToUnixTimeStamp()
        pHandle = StzEngineDateTimeNew(@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond)
        _nUnix_ = StzEngineDateTimeToUnix(pHandle)
        StzEngineDateTimeFree(pHandle)
        return _nUnix_

    def ToUnixTimeStampMs()
        return This._ToMsSinceEpoch()

	#--- EPOCH CONVERSIONS ---#

	# Returns the whole seconds from an origin to the datetime; an empty origin means 1970-01-01.
	#
	#   _cOrigin_   the origin name as a symbol or lowercase text, such as :UnixEpoch, :YearOne,
	#               :AtomicAge
	#   returns     a number of seconds
	#   note        rounds down
	#   warning     an origin written as mixed-case text such as "YearOne" is not recognised and
	#               counts as the Unix epoch
	#   see         ToMillisecondsSinceEpochXT, ToUnixTimeStamp
	def ToSecondsSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nCurrentMs_ = This._ToMsSinceEpoch()
	        _nOriginMs_ = This.GetOriginBase(_cOrigin_)
	        return floor((_nCurrentMs_ - _nOriginMs_) / 1000)

	# Returns the milliseconds from an origin to the datetime; an empty origin means 1970-01-01.
	#
	#   _cOrigin_   the origin name as a symbol or lowercase text, such as :UnixEpoch, :YearOne,
	#               :AtomicAge
	#   returns     a number of milliseconds
	#   warning     an origin written as mixed-case text such as "YearOne" is not recognised and
	#               counts as the Unix epoch
	#   see         ToSecondsSinceEpochXT
	def ToMillisecondsSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        _nCurrentMs_ = This._ToMsSinceEpoch()
	        _nOriginMs_ = This.GetOriginBase(_cOrigin_)
	        return _nCurrentMs_ - _nOriginMs_

	# Returns the whole minutes from an origin to the datetime; an empty origin means 1970-01-01.
	#
	#   _cOrigin_   the origin name as a symbol or lowercase text, such as :UnixEpoch, :YearOne,
	#               :AtomicAge
	#   returns     a number of minutes
	#   note        rounds down
	#   warning     an origin written as mixed-case text such as "YearOne" is not recognised and
	#               counts as the Unix epoch
	#   see         ToSecondsSinceEpochXT, ToHoursSinceEpochXT
	def ToMinutesSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToSecondsSinceEpochXT(_cOrigin_) / 60)

	# Returns the whole hours from an origin to the datetime; an empty origin means 1970-01-01.
	#
	#   _cOrigin_   the origin name as a symbol or lowercase text, such as :UnixEpoch, :YearOne,
	#               :AtomicAge
	#   returns     a number of hours
	#   note        rounds down
	#   warning     an origin written as mixed-case text such as "YearOne" is not recognised and
	#               counts as the Unix epoch
	#   see         ToMinutesSinceEpochXT, ToDaysSinceEpochXT
	def ToHoursSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToSecondsSinceEpochXT(_cOrigin_) / 3600)

	# Returns the whole days from an origin to the datetime; an empty origin means 1970-01-01.
	#
	#   _cOrigin_   the origin name as a symbol or lowercase text, such as :UnixEpoch, :YearOne,
	#               :AtomicAge
	#   returns     a number of days
	#   note        rounds down
	#   warning     an origin written as mixed-case text such as "YearOne" is not recognised and
	#               counts as the Unix epoch
	#   see         ToHoursSinceEpochXT, ToWeeksSinceEpochXT
	def ToDaysSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToSecondsSinceEpochXT(_cOrigin_) / 86400)

	# Returns the whole weeks of 7 days from an origin to the datetime; an empty origin means 1970-01-01.
	#
	#   _cOrigin_   the origin name as a symbol or lowercase text, such as :UnixEpoch, :YearOne,
	#               :AtomicAge
	#   returns     a number of weeks
	#   note        rounds down
	#   warning     an origin written as mixed-case text such as "YearOne" is not recognised and
	#               counts as the Unix epoch
	#   see         ToDaysSinceEpochXT
	def ToWeeksSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToSecondsSinceEpochXT(_cOrigin_) / 604800)

	# Returns the calendar months from an origin's month to the datetime's month, ignoring the day; an empty origin means January 1970.
	#
	#   _cOrigin_   the origin name as a symbol or lowercase text, such as :UnixEpoch, :YearOne,
	#               :AtomicAge
	#   returns     a number of months
	#   note        counts month numbers, so 31 March to 1 April is 1
	#   warning     wrong for every origin before 1970, because the origin's own date comes out as
	#               year 0 (:AtomicAge gives 24315 instead of 968); mixed-case origin text counts as
	#               the Unix epoch
	#   see         ToYearsSinceEpochXT
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

	# Returns the whole calendar years from an origin to the datetime, counting a year only once its month and day are reached.
	#
	#   _cOrigin_   the origin name as a symbol or lowercase text, such as :UnixEpoch, :YearOne,
	#               :AtomicAge
	#   returns     a number of years
	#   warning     wrong for every origin before 1970, because the origin's own date comes out as
	#               year 0 (:AtomicAge gives 2026 instead of 80); mixed-case origin text counts as
	#               the Unix epoch
	#   see         ToMonthsSinceEpochXT, ToDecadesSinceEpochXT
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

	# Returns the whole decades, a tenth of the whole years, from an origin to the datetime.
	#
	#   _cOrigin_   the origin name as a symbol or lowercase text, such as :UnixEpoch, :YearOne,
	#               :AtomicAge
	#   returns     a number of decades
	#   warning     wrong for every origin before 1970, because the year count is wrong there
	#   see         ToYearsSinceEpochXT, ToCenturiesSinceEpochXT
	def ToDecadesSinceEpochXT(_cOrigin_)
		if _cOrigin_ = ""
			_cOrigin_ = :UnixEpoch
		ok
	        return floor(This.ToYearsSinceEpochXT(_cOrigin_) / 10)

	# Returns the whole centuries, a hundredth of the whole years, from an origin to the datetime.
	#
	#   _cOrigin_   the origin name as a symbol or lowercase text, such as :UnixEpoch, :YearOne,
	#               :AtomicAge
	#   returns     a number of centuries
	#   warning     wrong for every origin before 1970, because the year count is wrong there
	#   see         ToDecadesSinceEpochXT
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

		# Returns the datetime text unchanged, as yyyy-MM-dd HH:mm:ss; no time-zone shift is applied.
		#
		#   returns    a string such as 2026-03-15 14:30:00
		#   note       the Q form returns a new stzDateTime holding the same fields
		#   warning    answers the same text as ToLocalTime today: the fields are taken as already
		#              being UTC
		#   see        ToUTCQ, ToLocalTime
		def ToUTC()
			return This.ToUTCQ().Content()

    def ToLocalTimeQ()
        _oNewDateTime_ = new stzDateTime("")
        _oNewDateTime_.SetComponents([@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs])
        return _oNewDateTime_

		# Returns the datetime text unchanged, as yyyy-MM-dd HH:mm:ss; no time-zone shift is applied.
		#
		#   returns    a string such as 2026-03-15 14:30:00
		#   note       the Q form returns a new stzDateTime holding the same fields
		#   warning    answers the same text as ToUTC today: the fields are never converted
		#   see        ToLocalTimeQ, ToUTC
		def ToLocalTime()
			return This.ToLocalTimeQ().Content()


	# Returns the year as a number such as 2026.
	#
	#   returns    a number
	#   see        Month, Day
	#--- TIME INFO
	def Year()
		return @nYear

		def YearN()
			return This.Year()

	# Returns the month of the year as a number from 1 to 12.
	#
	#   returns    a number
	#   see        Year, Day
	def Month()
		return @nMonth

		# Returns the month of the year as a number from 1 to 12.
		#
		#   returns    a number
		#   see        Month
		def MonthN()
			return @nMonth

	# Returns the day of the month as a number from 1 to 31.
	#
	#   returns    a number
	#   see        Month, DayN
	def Day()
		return @nDay

		# Returns the day of the month as a number from 1 to 31.
		#
		#   returns    a number
		#   see        Day
		def DayN()
			return @nDay

	# Returns the hour of the day on the 24-hour clock, from 0 to 23.
	#
	#   returns    a number
	#   see        Minutes, Seconds
	def Hours()
		return @nHour

		def HoursN()
			return This.Hours()

	# Returns the minute of the hour, from 0 to 59.
	#
	#   returns    a number
	#   see        Hours, Seconds
	def Minutes()
		return @nMinute

		def MinutesN()
			return This.Minutes()

	# Returns the second of the minute, from 0 to 59.
	#
	#   returns    a number
	#   see        Minutes, MilliSeconds
	def Seconds()
		return @nSecond

		def SecondsN()
			return This.Seconds()

	# Returns the millisecond part, from 0 to 999.
	#
	#   returns    a number
	#   see        Seconds
	def MilliSeconds()
		return @nMs

		def MilliSecondsN()
			return This.MilliSeconds()

		def MSeconds()
			return This.MilliSeconds()

		def MSecondsN()
			return This.MilliSeconds()


    #--- FORMATTING ---#

    # Returns the datetime as yyyy-MM-dd HH:mm:ss text, with .zzz added when the milliseconds are not zero.
    #
    #   returns    a string such as 2026-03-15 14:30:00
    #   note       does not change the object; the day and month are zero padded
    #   see        Content, ToIso
    def ToString()
        return This.ToStringXT("")

		# Returns the held datetime as yyyy-MM-dd HH:mm:ss text, with .zzz added when the milliseconds are not zero.
		#
		#   returns    a string such as 2026-03-15 14:30:00
		#   note       the text form is the content of the object
		#   see        ToString, Components
		def Content()
			return This.ToStringXT("")

		# Returns the datetime as yyyy-MM-dd HH:mm:ss text, with .zzz added when the milliseconds are not zero.
		#
		#   returns    a string such as 2026-03-15 14:30:00
		#   see        ToString, Content
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

	# Returns day/month and a 12-hour time without seconds, such as 15/03 2:30 PM.
	#
	#   returns    a string
	#   note       the 12-hour form is the default of this family; every 12h, AP and AmPm spelling
	#              gives the same text
	#   see        ToShort24h, ToMedium
	#@ aka  Short formats
	def ToShort()
	    return This.ToStringXT(:Short12h)

		# Returns day/month and a 12-hour time without seconds, such as 15/03 2:30 PM, the explicit 12-hour spelling.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToShort24h, ToMedium
		def ToShort12h()
		    return This.ToStringXT(:Short12h)

		# Returns day/month and a 12-hour time without seconds, such as 15/03 2:30 PM, spelled with the AP marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToShort24h, ToMedium
		def ToShortAP()
		    return This.ToStringXT(:Short12h)

		# Returns day/month and a 12-hour time without seconds, such as 15/03 2:30 PM, spelled with the AmPm marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToShort24h, ToMedium
		def ToShortAmPm()
		    return This.ToStringXT(:Short12h)

		# Returns day/month and a 12-hour time without seconds, such as 15/03 2:30 PM, spelled WithAP.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToShort24h, ToMedium
		def ToShortWithAP()
		    return This.ToStringXT(:Short12h)

		# Returns day/month and a 12-hour time without seconds, such as 15/03 2:30 PM, spelled WithAmPm.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToShort24h, ToMedium
		def ToShortWithAmPm()
		    return This.ToStringXT(:Short12h)

	# Returns day/month and a 24-hour time without seconds, such as 15/03 14:30.
	#
	#   returns    a string
	#   note       AM/PM is left out; every 24h and WithoutAP spelling gives the same text
	#   see        ToShort, ToMedium
	def ToShort24h()
	    return This.ToStringXT(:Short24h)

		# Returns day/month and a 24-hour time without seconds, such as 15/03 14:30, with no AM/PM marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToShort, ToMedium
		def ToShortWithoutAP()
		    return This.ToStringXT(:Short24h)

		# Returns day/month and a 24-hour time without seconds, such as 15/03 14:30, with no AmPm marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToShort, ToMedium
		def ToShortWithoutAmPm()
		    return This.ToStringXT(:Short24h)

	# Returns weekday, month and day with a 12-hour time, such as Sun, Mar 15 2:30 PM.
	#
	#   returns    a string
	#   note       the 12-hour form is the default of this family; every 12h, AP and AmPm spelling
	#              gives the same text
	#   see        ToMedium24h, ToCompact
	#@ aka  Medium formats
	def ToMedium()
	    return This.ToStringXT(:Medium12h)

		# Returns weekday, month and day with a 12-hour time, such as Sun, Mar 15 2:30 PM, the explicit 12-hour spelling.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToMedium24h, ToCompact
		def ToMedium12h()
		    return This.ToStringXT(:Medium12h)

		# Returns weekday, month and day with a 12-hour time, such as Sun, Mar 15 2:30 PM, spelled with the AP marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToMedium24h, ToCompact
		def ToMediumAP()
		    return This.ToStringXT(:Medium12h)

		# Returns weekday, month and day with a 12-hour time, such as Sun, Mar 15 2:30 PM, spelled with the AmPm marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToMedium24h, ToCompact
		def ToMediumAmPm()
		    return This.ToStringXT(:Medium12h)

		# Returns weekday, month and day with a 12-hour time, such as Sun, Mar 15 2:30 PM, spelled WithAP.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToMedium24h, ToCompact
		def ToMediumWithAP()
		    return This.ToStringXT(:Medium12h)

		# Returns weekday, month and day with a 12-hour time, such as Sun, Mar 15 2:30 PM, spelled WithAmPm.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToMedium24h, ToCompact
		def ToMediumWithAmPm()
		    return This.ToStringXT(:Medium12h)

	# Returns weekday, month and day with a 24-hour time, such as Sun, Mar 15 14:30.
	#
	#   returns    a string
	#   note       AM/PM is left out; every 24h and WithoutAP spelling gives the same text
	#   see        ToMedium, ToCompact
	def ToMedium24h()
	    return This.ToStringXT(:Medium24h)

		# Returns weekday, month and day with a 24-hour time, such as Sun, Mar 15 14:30, with no AM/PM marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToMedium, ToCompact
		def ToMediumWithoutAP()
		    return This.ToStringXT(:Medium24h)

		# Returns weekday, month and day with a 24-hour time, such as Sun, Mar 15 14:30, with no AmPm marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToMedium, ToCompact
		def ToMediumWithoutAmPm()
		    return This.ToStringXT(:Medium24h)

	# Returns year-month-day and a 12-hour time without seconds, such as 2026-03-15 02:30 PM.
	#
	#   returns    a string
	#   note       the 12-hour form is the default of this family; every 12h, AP and AmPm spelling
	#              gives the same text
	#   see        ToCompact24h, ToStandard
	#@ aka  --
	def ToCompact()
	    return This.ToStringXT(:Compact12h)

		# Returns year-month-day and a 12-hour time without seconds, such as 2026-03-15 02:30 PM, the explicit 12-hour spelling.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToCompact24h, ToStandard
		def ToCompact12h()
		    return This.ToStringXT(:Compact12h)

		# Returns year-month-day and a 12-hour time without seconds, such as 2026-03-15 02:30 PM, spelled with the AP marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToCompact24h, ToStandard
		def ToCompactAP()
		    return This.ToStringXT(:Compact12h)

		# Returns year-month-day and a 12-hour time without seconds, such as 2026-03-15 02:30 PM, spelled with the AmPm marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToCompact24h, ToStandard
		def ToCompactAmPm()
		    return This.ToStringXT(:Compact12h)

		# Returns year-month-day and a 12-hour time without seconds, such as 2026-03-15 02:30 PM, spelled WithAP.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToCompact24h, ToStandard
		def ToCompactWithAP()
		    return This.ToStringXT(:Compact12h)

		# Returns year-month-day and a 12-hour time without seconds, such as 2026-03-15 02:30 PM, spelled WithAmPm.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToCompact24h, ToStandard
		def ToCompactWithAmPm()
		    return This.ToStringXT(:Compact12h)

	# Returns year-month-day and a 24-hour time without seconds, such as 2026-03-15 14:30.
	#
	#   returns    a string
	#   note       AM/PM is left out; every 24h and WithoutAP spelling gives the same text
	#   see        ToCompact, ToStandard
	def ToCompact24h()
	    return This.ToStringXT(:Compact24h)

		# Returns year-month-day and a 24-hour time without seconds, such as 2026-03-15 14:30, with no AM/PM marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToCompact, ToStandard
		def ToCompactWithoutAP()
		    return This.ToStringXT(:Compact24h)

		# Returns year-month-day and a 24-hour time without seconds, such as 2026-03-15 14:30, with no AmPm marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToCompact, ToStandard
		def ToCompactWithoutAmPm()
		    return This.ToStringXT(:Compact24h)

	# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM.
	#
	#   returns    a string
	#   note       the 12-hour form is the default of this family; every 12h, AP and AmPm spelling
	#              gives the same text
	#   see        ToStandard24h, ToEuropean
	#@ aka  --
	def ToStandard()
	    return This.ToStringXT(:Standard12h)

		# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM, the explicit 12-hour spelling.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToStandard24h, ToEuropean
		def ToStandard12h()
		    return This.ToStringXT(:Standard12h)

		# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM, spelled with the AP marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToStandard24h, ToEuropean
		def ToStandardAP()
		    return This.ToStringXT(:Standard12h)

		# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM, spelled with the AmPm marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToStandard24h, ToEuropean
		def ToStandardAmPm()
		    return This.ToStringXT(:Standard12h)

		# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM, spelled WithAP.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToStandard24h, ToEuropean
		def ToStandardWithAP()
		    return This.ToStringXT(:Standard12h)

		# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM, spelled WithAmPm.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToStandard24h, ToEuropean
		def ToStandardWithAmPm()
		    return This.ToStringXT(:Standard12h)

	# Returns day/month/year and a 24-hour time with seconds, such as 15/03/2026 14:30:00.
	#
	#   returns    a string
	#   note       AM/PM is left out; every 24h and WithoutAP spelling gives the same text
	#   see        ToStandard, ToEuropean
	def ToStandard24h()
	    return This.ToStringXT(:Standard24h)

		# Returns day/month/year and a 24-hour time with seconds, such as 15/03/2026 14:30:00, with no AM/PM marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToStandard, ToEuropean
		def ToStandardWithoutAP()
		    return This.ToStringXT(:Standard24h)

		# Returns day/month/year and a 24-hour time with seconds, such as 15/03/2026 14:30:00, with no AmPm marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToStandard, ToEuropean
		def ToStandardWithoutAmPm()
		    return This.ToStringXT(:Standard24h)

	# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM.
	#
	#   returns    a string
	#   note       the layout is the same as the Standard family: the library keeps no separate
	#              European order
	#   see        ToEuropean24h, ToAmerican
	#@ aka  --
	def ToEuropean()
	    return This.ToStringXT(:European12h)

		# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM, the explicit 12-hour spelling.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToEuropean24h, ToAmerican
		def ToEuropean12h()
		    return This.ToStringXT(:European12h)

		# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM, spelled with the AP marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToEuropean24h, ToAmerican
		def ToEuropeanAP()
		    return This.ToStringXT(:European12h)

		# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM, spelled with the AmPm marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToEuropean24h, ToAmerican
		def ToEuropeanAmPm()
		    return This.ToStringXT(:European12h)

		# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM, spelled WithAP.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToEuropean24h, ToAmerican
		def ToEuropeanWithAP()
		    return This.ToStringXT(:European12h)

		# Returns day/month/year and a 12-hour time with seconds, such as 15/03/2026 02:30:00 PM, spelled WithAmPm.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToEuropean24h, ToAmerican
		def ToEuropeanWithAmPm()
		    return This.ToStringXT(:European12h)

	# Returns day/month/year and a 24-hour time with seconds, such as 15/03/2026 14:30:00.
	#
	#   returns    a string
	#   note       AM/PM is left out; every 24h and WithoutAP spelling gives the same text
	#   see        ToEuropean, ToAmerican
	def ToEuropean24h()
	    return This.ToStringXT(:European24h)

		# Returns day/month/year and a 24-hour time with seconds, such as 15/03/2026 14:30:00, with no AM/PM marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToEuropean, ToAmerican
		def ToEuropeanWithoutAP()
		    return This.ToStringXT(:European24h)

		# Returns day/month/year and a 24-hour time with seconds, such as 15/03/2026 14:30:00, with no AmPm marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToEuropean, ToAmerican
		def ToEuropeanWithoutAmPm()
		    return This.ToStringXT(:European24h)

	# Returns month/day/year and a 12-hour time with seconds, such as 03/15/2026 02:30:00 PM.
	#
	#   returns    a string
	#   note       the 12-hour form is the default of this family; every 12h, AP and AmPm spelling
	#              gives the same text
	#   see        ToAmerican24h, ToIso
	#@ aka  --
	def ToAmerican()
	    return This.ToStringXT(:American12h)

		# Returns month/day/year and a 12-hour time with seconds, such as 03/15/2026 02:30:00 PM, the explicit 12-hour spelling.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToAmerican24h, ToIso
		def ToAmerican12h()
		    return This.ToStringXT(:American12h)

		# Returns month/day/year and a 12-hour time with seconds, such as 03/15/2026 02:30:00 PM, spelled with the AP marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToAmerican24h, ToIso
		def ToAmericanAP()
		    return This.ToStringXT(:American12h)

		# Returns month/day/year and a 12-hour time with seconds, such as 03/15/2026 02:30:00 PM, spelled with the AmPm marker.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToAmerican24h, ToIso
		def ToAmericanAmPm()
		    return This.ToStringXT(:American12h)

		# Returns month/day/year and a 12-hour time with seconds, such as 03/15/2026 02:30:00 PM, spelled WithAP.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToAmerican24h, ToIso
		def ToAmericanWithAP()
		    return This.ToStringXT(:American12h)

		# Returns month/day/year and a 12-hour time with seconds, such as 03/15/2026 02:30:00 PM, spelled WithAmPm.
		#
		#   returns    a string
		#   note       same text as the plain form
		#   see        ToAmerican24h, ToIso
		def ToAmericanWithAmPm()
		    return This.ToStringXT(:American12h)

	# Returns month/day/year and a 24-hour time with seconds, such as 03/15/2026 14:30:00.
	#
	#   returns    a string
	#   note       AM/PM is left out; every 24h and WithoutAP spelling gives the same text
	#   see        ToAmerican, ToIso
	def ToAmerican24h()
	    return This.ToStringXT(:American24h)

		# Returns month/day/year and a 24-hour time with seconds, such as 03/15/2026 14:30:00, with no AM/PM marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToAmerican, ToIso
		def ToAmericanWithoutAP()
		    return This.ToStringXT(:American24h)

		# Returns month/day/year and a 24-hour time with seconds, such as 03/15/2026 14:30:00, with no AmPm marker.
		#
		#   returns    a string
		#   note       same text as the 24h form
		#   see        ToAmerican, ToIso
		def ToAmericanWithoutAmPm()
		    return This.ToStringXT(:American24h)

	# Returns the datetime as yyyy-MM-dd HH:mm:ss, the locale-free 24-hour form that is safe to store.
	#
	#   returns    a string such as 2026-03-15 14:30:00
	#   note       milliseconds are left out; ToIsoWithMs keeps them
	#   see        ToIso8601, ToIsoWithMs
	#@ aka  --
	def ToIso()
	    return This.ToStringXT(:Iso24h)

	# Returns the datetime as yyyy-MM-ddTHH:mm:ss, with a T between date and time.
	#
	#   returns    a string such as 2026-03-15T14:30:00
	#   note       no zone suffix is added and the milliseconds are left out
	#   see        ToIso
	def ToIso8601()
	    return This.ToStringXT(:ISO8601)

	# Returns the datetime as yyyy-MM-dd HH:mm:ss.zzz, always showing three digits of milliseconds.
	#
	#   returns    a string such as 2026-03-15 14:30:00.250
	#   note       shows .000 when the milliseconds are zero
	#   see        ToIso
	def ToIsoWithMs()
	    return This.ToStringXT(:ISOWithMs)

	# Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today.
	#
	#   returns    a string
	#   note       the intended text is weekday, month day, year and a time with seconds
	#   warning    the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00
	#              PM) because the single d of the pattern is never replaced; ToLong prints the day
	#              correctly
	#   see        ToLong, ToVerbose24h
	#@ aka  --
	def ToVerbose()
	    return This.ToStringXT(:Verbose12h)

		# Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today.
		#
		#   returns    a string
		#   note       the intended text is weekday, month day, year and a time with seconds
		#   warning    the day of the month comes out as the letter d (Sunday, March d, 2026
		#              02:30:00 PM) because the single d of the pattern is never replaced; ToLong
		#              prints the day correctly
		#   see        ToLong, ToVerbose24h
		def ToVerbose12h()
		    return This.ToStringXT(:Verbose12h)

		# Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today.
		#
		#   returns    a string
		#   note       the intended text is weekday, month day, year and a time with seconds
		#   warning    the day of the month comes out as the letter d (Sunday, March d, 2026
		#              02:30:00 PM) because the single d of the pattern is never replaced; ToLong
		#              prints the day correctly
		#   see        ToLong, ToVerbose24h
		def ToVerboseAP()
		    return This.ToStringXT(:Verbose12h)

		# Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today.
		#
		#   returns    a string
		#   note       the intended text is weekday, month day, year and a time with seconds
		#   warning    the day of the month comes out as the letter d (Sunday, March d, 2026
		#              02:30:00 PM) because the single d of the pattern is never replaced; ToLong
		#              prints the day correctly
		#   see        ToLong, ToVerbose24h
		def ToVerboseAmPm()
		    return This.ToStringXT(:Verbose12h)

		# Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today.
		#
		#   returns    a string
		#   note       the intended text is weekday, month day, year and a time with seconds
		#   warning    the day of the month comes out as the letter d (Sunday, March d, 2026
		#              02:30:00 PM) because the single d of the pattern is never replaced; ToLong
		#              prints the day correctly
		#   see        ToLong, ToVerbose24h
		def ToVerboseWithAP()
		    return This.ToStringXT(:Verbose12h)

		# Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today.
		#
		#   returns    a string
		#   note       the intended text is weekday, month day, year and a time with seconds
		#   warning    the day of the month comes out as the letter d (Sunday, March d, 2026
		#              02:30:00 PM) because the single d of the pattern is never replaced; ToLong
		#              prints the day correctly
		#   see        ToLong, ToVerbose24h
		def ToVerboseWithAmPm()
		    return This.ToStringXT(:Verbose12h)

	# Returns the weekday, month name, year and a 24-hour time, with the day number printed as the letter d today.
	#
	#   returns    a string
	#   note       the intended text is weekday, month day, year and a time with seconds
	#   warning    the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00
	#              PM) because the single d of the pattern is never replaced; ToLong prints the day
	#              correctly
	#   see        ToLong24h, ToVerbose
	def ToVerbose24h()
	    return This.ToStringXT(:Verbose24h)

		# Returns the weekday, month name, year and a 24-hour time, with the day number printed as the letter d today.
		#
		#   returns    a string
		#   note       the intended text is weekday, month day, year and a time with seconds
		#   warning    the day of the month comes out as the letter d (Sunday, March d, 2026
		#              02:30:00 PM) because the single d of the pattern is never replaced; ToLong
		#              prints the day correctly
		#   see        ToLong24h, ToVerbose
		def ToVerboseWithoutAP()
		    return This.ToStringXT(:Verbose24h)

		# Returns the weekday, month name, year and a 24-hour time, with the day number printed as the letter d today.
		#
		#   returns    a string
		#   note       the intended text is weekday, month day, year and a time with seconds
		#   warning    the day of the month comes out as the letter d (Sunday, March d, 2026
		#              02:30:00 PM) because the single d of the pattern is never replaced; ToLong
		#              prints the day correctly
		#   see        ToLong24h, ToVerbose
		def ToVerboseWithoutAmPm()
		    return This.ToStringXT(:Verbose24h)

    # Returns the day, abbreviated month, year and 24-hour time as dd MMM yyyy HH:mm:ss.
    #
    #   returns    a string such as 15 Mar 2026 14:30:00
    #   note       not the full RFC 2822 form: the weekday and the zone offset are absent
    #   see        ToTextDate, ToIso
	#----
    def ToRFC2822()
        return This.ToStringXT("dd MMM yyyy HH:mm:ss")

    # Returns the weekday, month and day with a 24-hour time and the year, in ddd MMM d HH:mm:ss yyyy order.
    #
    #   returns    a string such as Sun Mar d 14:30:00 2026 today
    #   note       the intended text is weekday, month, day, time and year
    #   warning    the day of the month comes out as the letter d (Sun Mar d 14:30:00 2026) because
    #              the single d of the pattern is never replaced
    #   see        ToRFC2822
    def ToTextDate()
        return This.ToStringXT("ddd MMM d HH:mm:ss yyyy")

	# Returns day/month/year with the hour on a 12-hour clock and an AM/PM marker, without seconds.
	#
	#   returns    a string such as 15/03/2026 2:30 PM
	#   note       the hour is not zero padded; the marker texts come from the default locale
	#   see        ToSimple24h, ToLong
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

		# Returns day/month/year with a 24-hour time, without seconds.
		#
		#   returns    a string such as 15/03/2026 14:30
		#   see        ToSimple
		def ToSimple24h()
		    return This.ToStringXT(:Simple24h)

	# Returns the weekday, month name, day, year and a 12-hour time with seconds and an AM/PM marker.
	#
	#   returns    a string such as Sunday, March 15, 2026 2:30:00 PM
	#   note       the day and month names are English; the hour is not zero padded
	#   see        ToLong24h, ToSimple
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

		# Returns the weekday, month name, year and a 24-hour time with seconds, with the day number printed as the letter d today.
		#
		#   returns    a string such as Sunday, March d, 2026 14:30:00 today
		#   note       the intended text is Sunday, March 15, 2026 14:30:00
		#   warning    the day of the month comes out as the letter d because the single d of the
		#              pattern is never replaced; ToLong prints the day correctly
		#   see        ToLong
		def ToLong24h()
		    return This.ToStringXT(:Long24h)

	# Returns the weekday, month name and year without a time, with the day number printed as the letter d today.
	#
	#   returns    a string such as Sunday, March d, 2026 today
	#   note       the intended text is Sunday, March 15, 2026
	#   warning    the day of the month comes out as the letter d because the single d of the
	#              pattern is never replaced
	#   see        ToLong
	def ToLongDate()
		return This.ToStringXT(:LongDate)

	# Returns yyyy-MM-dd with the time on a 12-hour clock, seconds and an AM/PM marker.
	#
	#   returns    a string such as 2026-03-15 2:30:00 PM
	#   note       the hour is not zero padded
	#   see        ToString, ToSimple
	def ToString12h()
	    _nHour12_ = StzConvertTo12Hour(@nHour)
	    _cAMPM_ = StzGetAmPmText(@nHour)

	    return _PadLeft("" + @nYear, 4, "0") + "-" + _PadLeft("" + @nMonth, 2, "0") + "-" + _PadLeft("" + @nDay, 2, "0") + " " + _nHour12_ + ":" +
	           _PadLeft("" + @nMinute, 2, "0") + ":" +
	           _PadLeft("" + @nSecond, 2, "0") + " " + _cAMPM_

    #--- HUMAN-READABLE ---#

    # Returns a sentence such as Sunday, March 15th, 2026 at Half past 2 PM, with the time said in words.
    #
    #   returns    a string
    #   note       whole times read 12 o'clock, quarter hours read Quarter past or Quarter to, other
    #              times read like 9:05 AM
    #   see        ToRelative, ToLong
    def ToHuman()
		_cDateHuman_ = This.DateQ().ToHuman()
        _cTimeHuman_ = This.TimeQ().ToHuman()

        return _cDateHuman_ + " at " + _cTimeHuman_

	# Returns how far the datetime is from the system clock in words, such as 5 minutes ago, in 3 hours or just now.
	#
	#   returns    a string
	#   note       under 60 seconds is just now; then minutes, hours, days, weeks, months of 30 days
	#              and years of 365 days, rounded to the nearest unit; depends on the clock when it
	#              is called
	#   see        ToHuman, IsNow
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

    # Returns a new stzDateTime holding the same date and time, so the copy can change without touching this one.
    #
    #   returns    a new stzDateTime
    #   note       the object is not changed
    #   see        ToUTCQ, Components
    def Copy()
        _oNewDateTime_ = new stzDateTime("")
        _oNewDateTime_.SetComponents([@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs])
        return _oNewDateTime_

    # Sets year, month, day, hour, minute, second and optionally millisecond from a list, and answers the object itself.
    #
    #   aComponents   a list [ year, month, day, hour, minute, second ] with an optional seventh
    #                 number for the milliseconds
    #   returns       the object itself, so calls can be chained
    #   note          the SetComponentsQ form gives the same result
    #   warning       does not check ranges, so a month of 13 is stored and IsValid then answers
    #                 FALSE; a list shorter than 6 numbers is ignored
    #   see           Components, IsValid
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

    # Returns the parts as the list [ year, month, day, hour, minute, second, milliseconds ].
    #
    #   returns    a list of 7 numbers
    #   see        SetComponents, Content
    def Components()
        return [@nYear, @nMonth, @nDay, @nHour, @nMinute, @nSecond, @nMs]

    # TRUE if the month is 1-12, the day exists in that month (leap years included) and the time fields are in range.
    #
    #   returns    TRUE or FALSE
    #   note       checks hour 0-23, minute 0-59, second 0-59 and milliseconds 0-999
    #   see        SetComponents
    def IsValid()
        if @nMonth < 1 or @nMonth > 12
            return 0
        ok
        if @nDay < 1 or @nDay > _DaysInMonth(@nYear, @nMonth)
            return 0
        ok
        if @nHour < 0 or @nHour > 23
            return 0
        ok
        if @nMinute < 0 or @nMinute > 59
            return 0
        ok
        if @nSecond < 0 or @nSecond > 59
            return 0
        ok
        if @nMs < 0 or @nMs > 999
            return 0
        ok
        return 1

    # TRUE if the object is a datetime object, which is always the case here; callers use it to tell classes apart.
    #
    #   returns    TRUE
    #   see        IsValid
    def IsAStzDateTime()
        return 1

	# TRUE if the text contains from epoch or since epoch, in any case.
	#
	#   cStr       the text to examine
	#   returns    TRUE or FALSE
	#   note       only the phrase is tested, not the amount before it
	#   see        ParseNaturalEpoch, IsCountingFromString
	def IsNaturalEpochString(cStr)
	    _cLower_ = StzLower(cStr)

	    if StzFindFirst("from epoch", _cLower_) > 0 or
	       StzFindFirst("since epoch", _cLower_) > 0
	        return 1
	    ok

	    return 0

	# Sets the object to 1970-01-01 plus a duration in words, but counts each plural unit more than once today (2 days gives 4).
	#
	#   _cNatural_   the duration in words ending with from epoch or since epoch, such as 3 days 2
	#                hours from epoch
	#   returns      nothing; the object changes in place
	#   note         FromNaturalEpoch reads the same words correctly; the constructor uses this
	#                method for text with from epoch or since epoch
	#   warning      counts every plural unit twice or three times: the unit list holds days and
	#                day, minutes, minute and min, seconds, second and sec, and each one is found
	#                inside the plural word, so 5 minutes gives 15 minutes and 2 days gives 4 days;
	#                singular units such as 1 week are right
	#   see          FromNaturalEpoch, IsNaturalEpochString
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

	# Sets the object to the first day of the month n calendar months after January 1970, at 00:00:00.
	#
	#   _nMonths_   the number of months since January 1970
	#   returns     nothing; the object changes in place
	#   note        the same as FromMonthsSinceEpoch with the Unix origin
	#   warning     a negative count leaves a month of 0 or less, an invalid date
	#   see         FromMonthsSinceEpoch
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

	# Sets the object to January 1 at 00:00:00 of the year 1970 plus n.
	#
	#   _nYears_   the number of years since 1970
	#   returns    nothing; the object changes in place
	#   see        FromYearsSinceEpoch
	def SetFromEpochYears(_nYears_)
	    @nYear = 1970 + _nYears_
	    @nMonth = 1
	    @nDay = 1
	    @nHour = 0
	    @nMinute = 0
	    @nSecond = 0
	    @nMs = 0

	# Sets the object to 1970-01-01 plus a hash of durations, milliseconds included, such as [ :days = 3, :milliseconds = 250 ].
	#
	#   aHash      a hash whose keys are years, months, weeks, days, hours, minutes, seconds or
	#              milliseconds
	#   returns    nothing; the object changes in place
	#   note       unlike FromEpochHash it reads the :milliseconds key
	#   warning    a negative total gives an invalid date
	#   see        FromEpochHash, HashToMilliseconds
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

    # TRUE if the text contains counting from, starting from or since, in any case.
    #
    #   cStr       the text to examine
    #   returns    TRUE or FALSE
    #   note       since alone is enough, so any text with since in it answers TRUE
    #   see        ParseCountingFrom, IsNaturalEpochString
    def IsCountingFromString(cStr)
        _cLower_ = StzLower(cStr)
        return (StzFindFirst("counting from", _cLower_) > 0) or
		(StzFindFirst("starting from", _cLower_) > 0) or
		(StzFindFirst("since", _cLower_) > 0)

    # Sets the object from a text such as 2 days counting from unix epoch (a duration, a phrase, an origin); does nothing without a phrase.
    #
    #   cStr       the text, a duration then counting from, starting from or since, then an origin
    #              name in words
    #   returns    nothing; the object changes in place
    #   note       the origin words are turned into an origin name by MapOriginName
    #   warning    an origin before 1970 (year one, atomic age...) leaves an invalid date today
    #   see        MapOriginName, SetFromNaturalDuration
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

    # Returns the origin name that matches words such as year one, atomic age or us independence; unknown words give unixepoch.
    #
    #   cName      the origin in words, any case
    #   returns    an origin name as lowercase text, such as yearone
    #   note       matching is by phrase: unix, year one or common era, islamic, space age, atomic
    #              age, us independence, french revolution, internet
    #   warning    modern computing is not recognised and answers unixepoch like any unknown text
    #   see        GetOriginBase, ParseCountingFrom
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

    # Sets the object to an origin plus a number of seconds, or plus a hash of durations; an empty origin means 1970-01-01.
    #
    #   _nValue_    the seconds after the origin, or a hash such as [ :hours = 5 ]
    #   _cOrigin_   the origin name as a symbol or lowercase text
    #   returns     nothing; the object changes in place
    #   note        seconds may carry a fraction, which becomes the milliseconds
    #   warning     every origin except :UnixEpoch lies before 1970 and leaves an invalid date
    #               today; mixed-case origin text counts as the Unix epoch
    #   see         GetOriginBase, SetFromNaturalDuration
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

    # Returns an origin's distance from 1970-01-01 in milliseconds, negative for earlier origins; 0 when the name is unknown.
    #
    #   _cOrigin_   the origin name as a symbol or lowercase text, such as :YearOne
    #   returns     a number of milliseconds
    #   note        the nine origins are UnixEpoch, YearOne, IslamicHijra, USIndependence,
    #               FrenchRevolution, AtomicAge, SpaceAge, InternetAge and ModernComputing
    #   warning     an origin written as mixed-case text such as "YearOne" is not found and answers
    #               0
    #   see         MapOriginName, SetCountingFrom
    def GetOriginBase(_cOrigin_)
        _nTimeOrigins1Len_ = len(aTimeOrigins)
        for _iLoopTimeOrigins1_ = 1 to _nTimeOrigins1Len_
        	_aOrigin_ = aTimeOrigins[_iLoopTimeOrigins1_]
            if _aOrigin_[1] = _cOrigin_
                return _aOrigin_[2]
            ok
        next
        return 0

    # Sets the object to an origin plus a duration in words such as 1 day 1 hour; an empty origin means 1970-01-01.
    #
    #   _cDuration_   the duration in words, numbers each followed by years, months, weeks, days,
    #                 hours, minutes or seconds
    #   _cOrigin_     the origin name as a symbol or lowercase text
    #   returns       nothing; the object changes in place
    #   note          a year counts 365 days and a month 30.4 days
    #   warning       an origin before 1970 leaves an invalid date today; milliseconds are not read
    #   see           ParseNaturalDuration, SetCountingFrom
    def SetFromNaturalDuration(_cDuration_, _cOrigin_)
	if _cOrigin_ = ""
		_cOrigin_ = :UnixEpoch
	ok
        _nDurationMs_ = This.ParseNaturalDuration(_cDuration_)
        _nBaseMs_ = This.GetOriginBase(_cOrigin_)
        This._SetFromMsSinceEpoch(_nBaseMs_ + _nDurationMs_)

    # Returns the milliseconds that a duration in words such as 10 minutes 5 seconds adds up to.
    #
    #   _cDuration_   the duration in words, numbers each followed by years, months, weeks, days,
    #                 hours, minutes or seconds
    #   returns       a number of milliseconds
    #   note          a year is 365 days and a month 30.4 days; the object is not changed
    #   warning       a word instead of a number (two days) raises R41; milliseconds are not read;
    #                 only the first amount of each unit counts
    #   see           HashToMilliseconds, FromNaturalEpoch
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

    # Returns the milliseconds that a hash of durations such as [ :days = 1, :hours = 1 ] adds up to.
    #
    #   aHash      a hash whose keys are years, months, weeks, days, hours, minutes or seconds
    #   returns    a number of milliseconds
    #   note       a year is 365 days and a month 30.4 days; the object is not changed
    #   warning    a :milliseconds key is ignored today
    #   see        SetFromEpochDuration, ParseNaturalDuration
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

	# Returns the distance from the datetime to a target in one unit, or a hash of all units when the unit is empty.
	#
	#   pTarget    the target datetime, as a stzDateTime or a date-time text
	#   pcUnit     the unit as text such as days, or written :In = :Days
	#   returns    a number in the unit, or a hash with keys milliseconds, seconds, minutes, hours,
	#              days, weeks, months, years, decades and centuries
	#   note       negative when the target is earlier; days and weeks round down, hours and smaller
	#              units can carry a fraction, months and years compare calendar numbers
	#   warning    an unknown unit raises Unsupported unit, and so does in days with a space
	#   see        DurationSince, DaysTo
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

	    if _cUnit_ = ""
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

	# Returns the milliseconds from the datetime to a target datetime, negative when the target is earlier.
	#
	#   pcUnit     the target datetime, as a stzDateTime or a date-time text
	#   returns    a number of milliseconds
	#   note       the object is not changed
	#   see        MillisecondsTo, MSecsTo, DurationTo
	def DurationInMillisecondsTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Milliseconds)

	    # Returns the milliseconds from the datetime to a target datetime, negative when the target is earlier.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a number of milliseconds
	    #   note       the object is not changed
	    #   see        DurationInMillisecondsTo, MSecsTo, DurationTo
	    def MillisecondsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Milliseconds)

	    # Returns the milliseconds from the datetime to a target datetime, negative when the target is earlier.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a number of milliseconds
	    #   note       the object is not changed
	    #   see        DurationInMillisecondsTo, MillisecondsTo, DurationTo
	    def MSecsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Milliseconds)

	# Returns the seconds from the datetime to a target datetime, negative when the target is earlier.
	#
	#   pcUnit     the target datetime, as a stzDateTime or a date-time text
	#   returns    a number of seconds, with a fraction when the milliseconds differ
	#   note       a fraction appears when the milliseconds differ
	#   see        SecondsTo, SecsTo, DurationTo
	def DurationInSecondsTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Seconds)

	    # Returns the seconds from the datetime to a target datetime, negative when the target is earlier.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a number of seconds, with a fraction when the milliseconds differ
	    #   note       a fraction appears when the milliseconds differ
	    #   see        DurationInSecondsTo, SecsTo, DurationTo
	    def SecondsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Seconds)

	    # Returns the seconds from the datetime to a target datetime, negative when the target is earlier.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a number of seconds, with a fraction when the milliseconds differ
	    #   note       a fraction appears when the milliseconds differ
	    #   see        DurationInSecondsTo, SecondsTo, DurationTo
	    def SecsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Seconds)

	# Returns the minutes from the datetime to a target datetime, with a fraction, negative when the target is earlier.
	#
	#   pcUnit     the target datetime, as a stzDateTime or a date-time text
	#   returns    a number of minutes, with a fraction
	#   note       the object is not changed
	#   see        MinutesTo, DurationTo
	def DurationInMinutesTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Minutes)

	    # Returns the minutes from the datetime to a target datetime, with a fraction, negative when the target is earlier.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a number of minutes, with a fraction
	    #   note       the object is not changed
	    #   see        DurationInMinutesTo, DurationTo
	    def MinutesTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Minutes)

	# Returns the hours from the datetime to a target datetime, with a fraction, negative when the target is earlier.
	#
	#   pcUnit     the target datetime, as a stzDateTime or a date-time text
	#   returns    a number of hours, with a fraction
	#   note       the object is not changed
	#   see        HoursTo, DurationTo
	def DurationInHoursTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Hours)

	    # Returns the hours from the datetime to a target datetime, with a fraction, negative when the target is earlier.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a number of hours, with a fraction
	    #   note       the object is not changed
	    #   see        DurationInHoursTo, DurationTo
	    def HoursTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :hours)

	# Returns the whole days from the datetime to a target datetime, rounded down, negative when the target is earlier.
	#
	#   pcUnit     the target datetime, as a stzDateTime or a date-time text
	#   returns    a whole number of days
	#   note       rounding is toward minus infinity, so 4.2 days earlier gives -5
	#   see        DaysTo, DurationTo
	def DurationInDaysTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Days)

	    # Returns the whole days from the datetime to a target datetime, rounded down, negative when the target is earlier.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a whole number of days
	    #   note       rounding is toward minus infinity, so 4.2 days earlier gives -5
	    #   see        DurationInDaysTo, DurationTo
	    def DaysTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Days)

	# Returns the whole weeks of 7 days from the datetime to a target datetime, rounded down.
	#
	#   pcUnit     the target datetime, as a stzDateTime or a date-time text
	#   returns    a whole number of weeks
	#   note       counted from the whole days, rounded down
	#   see        WeeksTo, DurationTo
	def DurationInWeeksTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Weeks)

	    # Returns the whole weeks of 7 days from the datetime to a target datetime, rounded down.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a whole number of weeks
	    #   note       counted from the whole days, rounded down
	    #   see        DurationInWeeksTo, DurationTo
	    def WeeksTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Weeks)

	# Returns how many calendar months apart the two datetimes are, by month number and ignoring the day.
	#
	#   pcUnit     the target datetime, as a stzDateTime or a date-time text
	#   returns    a whole number of calendar months
	#   note       15 March to 1 April is 1 month, and 15 March to 14 April is also 1
	#   see        MonthsTo, DurationTo
	def DurationInMonthsTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Months)

	    # Returns how many calendar months apart the two datetimes are, by month number and ignoring the day.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a whole number of calendar months
	    #   note       15 March to 1 April is 1 month, and 15 March to 14 April is also 1
	    #   see        DurationInMonthsTo, DurationTo
	    def MonthsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Months)

	# Returns how many calendar years apart the two datetimes are, by year number and ignoring month and day.
	#
	#   pcUnit     the target datetime, as a stzDateTime or a date-time text
	#   returns    a whole number of calendar years
	#   note       15 March 2026 to 14 March 2027 is 1 year
	#   see        YearsTo, DurationTo
	def DurationInYearsTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Years)

	    # Returns how many calendar years apart the two datetimes are, by year number and ignoring month and day.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a whole number of calendar years
	    #   note       15 March 2026 to 14 March 2027 is 1 year
	    #   see        DurationInYearsTo, DurationTo
	    def YearsTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Years)

	# Raises error R24 today instead of returning the decades from the datetime to a target datetime.
	#
	#   cTo        the target datetime, as a stzDateTime or a date-time text
	#   returns    nothing today; the call raises
	#   note       the object is not changed
	#   warning    raises R24 today instead of answering the decades: the parameter is named cTo but
	#              the body reads pcUnit, which does not exist there; DecadesTo works
	#   see        DecadesTo, DurationTo
	def DurationInDecadesTo(cTo)
	    return This.DurationTo(pcUnit, :In = :Decades)

	    # Returns a tenth of the calendar years between the two datetimes, rounded down.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a whole number of decades
	    #   note       built on the year difference
	    #   see        DurationInDecadesTo, DurationTo
	    def DecadesTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Decades)

	# Returns a hundredth of the calendar years between the two datetimes, rounded down.
	#
	#   pcUnit     the target datetime, as a stzDateTime or a date-time text
	#   returns    a whole number of centuries
	#   note       built on the year difference
	#   see        CenturiesTo, DurationTo
	def DurationInCenturiesTo(pcUnit)
	    return This.DurationTo(pcUnit, :In = :Centuries)

	    # Returns a hundredth of the calendar years between the two datetimes, rounded down.
	    #
	    #   pcUnit     the target datetime, as a stzDateTime or a date-time text
	    #   returns    a whole number of centuries
	    #   note       built on the year difference
	    #   see        DurationInCenturiesTo, DurationTo
	    def CenturiesTo(pcUnit)
	        return This.DurationTo(pcUnit, :In = :Centuries)

        #--- DURATION CALCULATIONS FROM A GIVEN ORIGIN OR DATETIME ---#

    # Returns the time elapsed from a named origin up to the datetime in one unit, or a hash of all units when the unit is empty.
    #
    #   pOrigin    the origin name as a symbol or lowercase text, such as :UnixEpoch or :YearOne
    #   pcUnit     the unit as text such as days, or written :In = :Days
    #   returns    a number in the unit, or a hash with keys milliseconds, seconds, minutes, hours,
    #              days, weeks, months, years, decades and centuries
    #   note       the origin is a name from the list of nine origins, not a datetime
    #   warning    an origin written as mixed-case text, or a datetime text, counts as the Unix
    #              epoch; months, years, decades and centuries are wrong for an origin before 1970
    #   see        DurationTo, ToSecondsSinceEpochXT
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

    # Returns the milliseconds elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
    #
    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
    #              :InternetAge or :ModernComputing
    #   returns    a number of milliseconds
    #   note       the object is not changed
    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text, is
    #              not recognised and counts as the Unix epoch
    #   see        MillisecondsFrom, DurationInMillisecondsSince, DurationSince
    def DurationInMillisecondsFrom(pOrigin)
        return This.DurationSince(pOrigin, :In = :Milliseconds)

	# Raises error R24 today instead of returning the milliseconds elapsed from a named origin up to the datetime.
	#
	#   cFrom      the origin the call was meant to take, as a symbol such as :UnixEpoch
	#   returns    nothing today; the call raises
	#   note       the object is not changed
	#   warning    raises R24 today: the parameter is named cFrom but the body reads pOrigin, which
	#              does not exist there; DurationInMillisecondsFrom works
	#   see        DurationInMillisecondsFrom, DurationSince
	def MillisecondsFrom(cFrom)
		return This.DurationSince(pOrigin, :In = :Milliseconds)

	    # Raises error R24 today instead of returning the milliseconds elapsed from a named origin up to the datetime.
	    #
	    #   cFrom      the origin the call was meant to take, as a symbol such as :UnixEpoch
	    #   returns    nothing today; the call raises
	    #   note       the object is not changed
	    #   warning    raises R24 today: the parameter is named cFrom but the body reads pOrigin,
	    #              which does not exist there; DurationInMillisecondsFrom works
	    #   see        DurationInMillisecondsFrom, DurationSince
	    def DurationInMillisecondsSince(cFrom)
	        return This.DurationSince(pOrigin, :In = :Milliseconds)

	# Raises error R24 today instead of returning the milliseconds elapsed from a named origin up to the datetime.
	#
	#   cFrom      the origin the call was meant to take, as a symbol such as :UnixEpoch
	#   returns    nothing today; the call raises
	#   note       the object is not changed
	#   warning    raises R24 today: the parameter is named cFrom but the body reads pOrigin, which
	#              does not exist there; DurationInMillisecondsFrom works
	#   see        DurationInMillisecondsFrom, DurationSince
	def MillisecondsSince(cFrom)
		return This.DurationSince(pOrigin, :In = :Milliseconds)

    # Returns the whole seconds elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
    #
    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
    #              :InternetAge or :ModernComputing
    #   returns    a whole number of seconds
    #   note       the object is not changed; rounds down
    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text, is
    #              not recognised and counts as the Unix epoch
    #   see        SecondsFrom, DurationInSecondsSince, DurationSince
    def DurationInSecondsFrom(pOrigin)
        return This.DurationSince(pOrigin, :In = :Seconds)

	    # Returns the whole seconds elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of seconds
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInSecondsFrom, DurationInSecondsSince, DurationSince
	    def SecondsFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Seconds)

	    # Returns the whole seconds elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of seconds
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInSecondsFrom, SecondsFrom, DurationSince
	    def DurationInSecondsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Seconds)

	    # Returns the whole seconds elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of seconds
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInSecondsFrom, SecondsFrom, DurationSince
	    def SecondsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Seconds)

    # Returns the whole minutes elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
    #
    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
    #              :InternetAge or :ModernComputing
    #   returns    a whole number of minutes
    #   note       the object is not changed; rounds down
    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text, is
    #              not recognised and counts as the Unix epoch
    #   see        MinutesFrom, DurationInMinutesSince, DurationSince
    def DurationInMinutesFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Minutes)

	    # Returns the whole minutes elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of minutes
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInMinutesFrom, DurationInMinutesSince, DurationSince
	    def MinutesFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Minutes)

	    # Returns the whole minutes elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of minutes
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInMinutesFrom, MinutesFrom, DurationSince
	    def DurationInMinutesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Minutes)

	    # Returns the whole minutes elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of minutes
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInMinutesFrom, MinutesFrom, DurationSince
	    def MinutesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Minutes)

    # Returns the whole hours elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
    #
    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
    #              :InternetAge or :ModernComputing
    #   returns    a whole number of hours
    #   note       the object is not changed; rounds down
    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text, is
    #              not recognised and counts as the Unix epoch
    #   see        HoursFrom, DurationInHoursSince, DurationSince
    def DurationInHoursFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Hours)

	    # Returns the whole hours elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of hours
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInHoursFrom, DurationInHoursSince, DurationSince
	    def HoursFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Hours)

	    # Returns the whole hours elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of hours
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInHoursFrom, HoursFrom, DurationSince
	    def DurationInHoursSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Hours)

	    # Returns the whole hours elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of hours
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInHoursFrom, HoursFrom, DurationSince
	    def HoursSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Hours)

    # Returns the whole days elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
    #
    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
    #              :InternetAge or :ModernComputing
    #   returns    a whole number of days
    #   note       the object is not changed; rounds down
    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text, is
    #              not recognised and counts as the Unix epoch
    #   see        DaysFrom, DurationInDaysSince, DurationSince
    def DurationInDaysFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Days)

	    # Returns the whole days elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of days
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInDaysFrom, DurationInDaysSince, DurationSince
	    def DaysFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Days)

	    # Returns the whole days elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of days
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInDaysFrom, DaysFrom, DurationSince
	    def DurationInDaysSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Days)

	    # Returns the whole days elapsed from a named origin such as :UnixEpoch or :YearOne up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of days
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInDaysFrom, DaysFrom, DurationSince
	    def DaysSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Days)

    # Returns the whole weeks of 7 days elapsed from a named origin up to the datetime.
    #
    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
    #              :InternetAge or :ModernComputing
    #   returns    a whole number of weeks
    #   note       the object is not changed; rounds down
    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text, is
    #              not recognised and counts as the Unix epoch
    #   see        WeeksFrom, DurationInWeeksSince, DurationSince
    def DurationInWeeksFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Weeks)

	    # Returns the whole weeks of 7 days elapsed from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of weeks
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInWeeksFrom, DurationInWeeksSince, DurationSince
	    def WeeksFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Weeks)

	    # Returns the whole weeks of 7 days elapsed from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of weeks
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInWeeksFrom, WeeksFrom, DurationSince
	    def DurationInWeeksSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Weeks)

	    # Returns the whole weeks of 7 days elapsed from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of weeks
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch
	    #   see        DurationInWeeksFrom, WeeksFrom, DurationSince
	    def WeeksSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Weeks)

    # Returns the calendar months from a named origin's month up to the datetime's month, ignoring the day.
    #
    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
    #              :InternetAge or :ModernComputing
    #   returns    a whole number of months
    #   note       the object is not changed; rounds down
    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text, is
    #              not recognised and counts as the Unix epoch; wrong for every origin before 1970,
    #              where the month and year of the origin come out as year 0
    #   see        MonthsFrom, DurationInMonthsSince, DurationSince
    def DurationInMonthsFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Months)

	    # Returns the calendar months from a named origin's month up to the datetime's month, ignoring the day.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of months
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInMonthsFrom, DurationInMonthsSince, DurationSince
	    def MonthsFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Months)

	    # Returns the calendar months from a named origin's month up to the datetime's month, ignoring the day.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of months
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInMonthsFrom, MonthsFrom, DurationSince
	    def DurationInMonthsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Months)

	    # Returns the calendar months from a named origin's month up to the datetime's month, ignoring the day.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of months
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInMonthsFrom, MonthsFrom, DurationSince
	    def MonthsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Months)

    # Returns the whole calendar years from a named origin up to the datetime.
    #
    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
    #              :InternetAge or :ModernComputing
    #   returns    a whole number of years
    #   note       the object is not changed; rounds down
    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text, is
    #              not recognised and counts as the Unix epoch; wrong for every origin before 1970,
    #              where the month and year of the origin come out as year 0
    #   see        YearsFrom, DurationInYearsSince, DurationSince
    def DurationInYearsFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Years)

	    # Returns the whole calendar years from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of years
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInYearsFrom, DurationInYearsSince, DurationSince
	    def YearsFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Years)

	    # Returns the whole calendar years from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of years
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInYearsFrom, YearsFrom, DurationSince
	    def DurationInYearsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Years)

	    # Returns the whole calendar years from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of years
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInYearsFrom, YearsFrom, DurationSince
	    def YearsSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Years)


    # Returns the whole decades, a tenth of the whole years, from a named origin up to the datetime.
    #
    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
    #              :InternetAge or :ModernComputing
    #   returns    a whole number of decades
    #   note       the object is not changed; rounds down
    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text, is
    #              not recognised and counts as the Unix epoch; wrong for every origin before 1970,
    #              where the month and year of the origin come out as year 0
    #   see        DecadesFrom, DurationInDecadesSince, DurationSince
    def DurationInDecadesFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Decades)

	    # Returns the whole decades, a tenth of the whole years, from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of decades
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInDecadesFrom, DurationInDecadesSince, DurationSince
	    def DecadesFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Decades)

	    # Returns the whole decades, a tenth of the whole years, from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of decades
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInDecadesFrom, DecadesFrom, DurationSince
	    def DurationInDecadesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Decades)

	    # Returns the whole decades, a tenth of the whole years, from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of decades
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInDecadesFrom, DecadesFrom, DurationSince
	    def DecadesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Decades)


    # Returns the whole centuries, a hundredth of the whole years, from a named origin up to the datetime.
    #
    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
    #              :InternetAge or :ModernComputing
    #   returns    a whole number of centuries
    #   note       the object is not changed; rounds down
    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text, is
    #              not recognised and counts as the Unix epoch; wrong for every origin before 1970,
    #              where the month and year of the origin come out as year 0
    #   see        CenturiesFrom, DurationInCenturiesSince, DurationSince
    def DurationInCenturiesFrom(pOrigin)
         return This.DurationSince(pOrigin, :In = :Centuries)

	    # Returns the whole centuries, a hundredth of the whole years, from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of centuries
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInCenturiesFrom, DurationInCenturiesSince, DurationSince
	    def CenturiesFrom(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Centuries)

	    # Returns the whole centuries, a hundredth of the whole years, from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of centuries
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInCenturiesFrom, CenturiesFrom, DurationSince
	    def DurationInCenturiesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Centuries)

	    # Returns the whole centuries, a hundredth of the whole years, from a named origin up to the datetime.
	    #
	    #   pOrigin    the origin name as a symbol or lowercase text: :UnixEpoch, :YearOne,
	    #              :IslamicHijra, :USIndependence, :FrenchRevolution, :AtomicAge, :SpaceAge,
	    #              :InternetAge or :ModernComputing
	    #   returns    a whole number of centuries
	    #   note       the object is not changed; rounds down
	    #   warning    an origin written as mixed-case text such as "YearOne", or a datetime text,
	    #              is not recognised and counts as the Unix epoch; wrong for every origin before
	    #              1970, where the month and year of the origin come out as year 0
	    #   see        DurationInCenturiesFrom, CenturiesFrom, DurationSince
	    def CenturiesSince(pOrigin)
	        return This.DurationSince(pOrigin, :In = :Centuries)

    # Sets the object from a hash with the keys :Year, :Month, :Day, :Hour, :Minute and :Second; a missing key takes its 2000-01-01 value.
    #
    #   aHash      a hash with any of the keys Year, Month, Day, Hour, Minute and Second, numbers or
    #              numeric text
    #   returns    nothing; the object changes in place
    #   warning    does not check ranges (month 14 is stored and IsValid answers FALSE); the
    #              milliseconds are reset to 0
    #   see        SetComponents, Components
    #@ aka  ===
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

	# Handles the symbols + - < <= > >= = between the datetime and a number, a text or another datetime, for the object's own use.
	#
	#   op         the operator as text: + - < <= > >= or =
	#   v          the right-hand value: a number of seconds, a duration text such as 2 days, a
	#              date-time text or a stzDateTime
	#   returns    the object after + with a number or a duration text; seconds after -; TRUE or
	#              FALSE for a comparison; nothing for other pairs
	#   note       a number v adds or subtracts that many seconds; a duration text goes through
	#              AddNatural or SubtractNatural
	#   warning    adding or subtracting changes the object itself, it does not make a new one; a -
	#              b answers the seconds from a to b, which is positive when b is later, the
	#              opposite sign of ordinary subtraction
	#   see        IsBefore, IsAfter, SecondsTo
	#@ aka  Operator overloading
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
