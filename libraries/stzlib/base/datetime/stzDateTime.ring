
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

Qt Format String Rules:
- h  = hour 0-23 (or 1-12 if AP present)
- hh = hour 00-23 (or 01-12 if AP present) with leading zero
- H  = same as h (Qt doesn't distinguish H from h)
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
    # These are processed with custom logic, not direct Qt format strings
    
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
    :UnixStart = 0,                      # 1970-01-01
    :YearOne = -62135596800000,          # 1 CE
    :IslamicCalendar = -42521587200000,  # 622 CE (Hijra)
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

func NowDateTime()
    return StzDateTimeQ("").ToString()

    func NowXT()
        return NowDateTime()

func NowXTQ()
	return StzDateTimeQ("")

func IsDateTime(str)
    if not isString(str)
        return FALSE
    ok

	Rx = new stzRegex(pat(:DateTime) )
	return Rx.Match(str)

    func IsValidDateTime(str)
        return IsDateTime(str)

# Helper function: Get format string by name or return as-is if custom
func GetDateTimeFormat(cFormatNameOrString)
    if isString(cFormatNameOrString)
        # Check if it's a named format
        for aFormat in $aDateTimeFormats
            if aFormat[1] = cFormatNameOrString
                return aFormat[2]
            ok
        next
        # Not a named format, treat as custom format string
        return cFormatNameOrString
    ok

    return $cDefaultDateTimeFormat


func Is12HourFormat(cFormat)
    # Get actual format string if it's a name
    cActualFormat = GetDateTimeFormat(cFormat)
    
    # Check for AP/ap marker (definitive 12h indicator)
    if substr(upper(cActualFormat), "AP") > 0
        return TRUE
    ok
    
    # Check for explicit 12h suffix in format name
    if isString(cFormat) and right(lower(cFormat), 3) = "12h"
        return TRUE
    ok
    
    return FALSE

func ConvertTo12Hour(nHour)
    nHour12 = nHour % 12
    if nHour12 = 0
        nHour12 = 12
    ok
    return nHour12

func GetAmPmText(nHour)
    oLocale = new stzLocale("")
    if nHour >= 12
        return oLocale.pmText()
    else
        return oLocale.amText()
    ok


class stzDateTime from stzObject
    @oQDateTime
    @nTotalSeconds

	def init(pDateTime)
	    @oQDateTime = new QDateTime()
	    @oQDateTime.setTimeSpec(0)  # Set to UTC (Qt::UTC = 0)
	    
	    if IsNull(pDateTime) or pDateTime = ""
	        @oQDateTime = @oQDateTime.currentDateTime()
	        @oQDateTime.setTimeSpec(0)
	        
	    but isString(pDateTime)
	        # Check if it's a counting from string
	        if This.IsCountingFromString(pDateTime)
	            This.ParseCountingFrom(pDateTime)
	        else
	            # Check if it's a natural epoch string (original)
	            if This.IsNaturalEpochString(pDateTime)
	                This.ParseNaturalEpoch(pDateTime)
	            else
	                This.ParseStringDateTime(pDateTime)
	            ok
	        ok
	        
	    but isNumber(pDateTime)
	        # Unix timestamp in seconds
	        @oQDateTime.setMSecsSinceEpoch(pDateTime * 1000)
	        
	    but isList(pDateTime)
	        if len(pDateTime) = 2 and 
	           isObject(pDateTime[1]) and isObject(pDateTime[2])
	            # [stzDate, stzTime] format
	            if pDateTime[1].IsAStzDate()
	                @oQDateTime.setDate(pDateTime[1].QDateObject())
	            ok
	            if pDateTime[2].IsAStzTime()
	                @oQDateTime.setTime(pDateTime[2].QTimeObject())
	            ok
	        
	        but IsHashList(pDateTime)
	            # CountingFrom with explicit origin
	            if pDateTime[:CountingFrom] != NULL
	                This.SetCountingFrom(pDateTime[:CountingFrom], pDateTime[:Origin])
	                
	            # CountingFrom specific origins
	            but pDateTime[:CountingFromUnixStart] != NULL
	                This.SetCountingFrom(pDateTime[:CountingFromUnixStart], :UnixStart)
	                
	            but pDateTime[:CountingFromYearOne] != NULL
	                This.SetCountingFrom(pDateTime[:CountingFromYearOne], :YearOne)
	                
	            but pDateTime[:CountingFromIslamicCalendar] != NULL
	                This.SetCountingFrom(pDateTime[:CountingFromIslamicCalendar], :IslamicCalendar)
	                
	            but pDateTime[:CountingFromUSIndependence] != NULL
	                This.SetCountingFrom(pDateTime[:CountingFromUSIndependence], :USIndependence)
	                
	            but pDateTime[:CountingFromSpaceAge] != NULL
	                This.SetCountingFrom(pDateTime[:CountingFromSpaceAge], :SpaceAge)
	                
	            but pDateTime[:CountingFromAtomicAge] != NULL
	                This.SetCountingFrom(pDateTime[:CountingFromAtomicAge], :AtomicAge)
	                
	            # Natural language with origin
	            but pDateTime[:NaturalDuration] != NULL
	                cOrigin = :UnixStart
	                if pDateTime[:Origin] != NULL
	                    cOrigin = pDateTime[:Origin]
	                ok
	                This.SetFromNaturalDuration(pDateTime[:NaturalDuration], cOrigin)
	                
	            # Original epoch-based creation
	            but pDateTime[:FromEpochSeconds] != NULL
	                @oQDateTime.setMSecsSinceEpoch(pDateTime[:FromEpochSeconds] * 1000)
	                
	            but pDateTime[:FromEpochMilliseconds] != NULL
	                @oQDateTime.setMSecsSinceEpoch(pDateTime[:FromEpochMilliseconds])
	                
	            but pDateTime[:FromEpochMinutes] != NULL
	                @oQDateTime.setMSecsSinceEpoch(pDateTime[:FromEpochMinutes] * 60 * 1000)
	                
	            but pDateTime[:FromEpochHours] != NULL
	                @oQDateTime.setMSecsSinceEpoch(pDateTime[:FromEpochHours] * 3600 * 1000)
	                
	            but pDateTime[:FromEpochDays] != NULL
	                @oQDateTime.setMSecsSinceEpoch(pDateTime[:FromEpochDays] * 86400 * 1000)
	                
	            but pDateTime[:FromEpochWeeks] != NULL
	                @oQDateTime.setMSecsSinceEpoch(pDateTime[:FromEpochWeeks] * 604800 * 1000)
	                
	            but pDateTime[:FromEpochMonths] != NULL
	                This.SetFromEpochMonths(pDateTime[:FromEpochMonths])
	                
	            but pDateTime[:FromEpochYears] != NULL
	                This.SetFromEpochYears(pDateTime[:FromEpochYears])
	                
	            but pDateTime[:FromNaturalEpoch] != NULL
	                This.ParseNaturalEpoch(pDateTime[:FromNaturalEpoch])
	                
	            but pDateTime[:FromEpochDuration] != NULL
	                This.SetFromEpochDuration(pDateTime[:FromEpochDuration])
	                
	            else
	                # Standard hash format: [:Year, :Month, :Day, :Hour, :Minute, :Second]
	                nYear = 2000
	                nMonth = 1
	                nDay = 1
	                nHour = 0
	                nMinute = 0
	                nSecond = 0
	                
	                if pDateTime[:Year] != NULL
	                    nYear = 0+ pDateTime[:Year]
	                ok
	                if pDateTime[:Month] != NULL
	                    nMonth = 0+ pDateTime[:Month]
	                ok
	                if pDateTime[:Day] != NULL
	                    nDay = 0+ pDateTime[:Day]
	                ok
	                if pDateTime[:Hour] != NULL
	                    nHour = 0+ pDateTime[:Hour]
	                ok
	                if pDateTime[:Minute] != NULL
	                    nMinute = 0+ pDateTime[:Minute]
	                ok
	                if pDateTime[:Second] != NULL
	                    nSecond = 0+ pDateTime[:Second]
	                ok
	                
	                _oDate_ = new QDate()
	                _oDate_.setDate(nYear, nMonth, nDay)
	                _oTime_ = new QTime()
	                _oTime_.setHMS(nHour, nMinute, nSecond, 0)
	                
	                @oQDateTime.setDate(_oDate_)
	                @oQDateTime.setTime(_oTime_)
	            ok
	        ok
	    ok
	    
	    if not @oQDateTime.isValid()
	        StzRaise("Invalid date/time provided!")
	    ok
    
    def ParseStringDateTime(cDateTime)
        # Try Qt built-in formats first (using numeric constants)
        aQtFormats = [ 1, 0 ] # ISODate=1, TextDate=0
        
        for nFormat in aQtFormats
            oTemp = new QDateTime()
            oTemp = oTemp.fromString(cDateTime, nFormat)
            
            if oTemp.isValid()
                @oQDateTime = oTemp
                return
            ok
        next
        
        # Try custom string formats
        aCustomFormats = [
            "yyyy-MM-dd h:m:s",
            "yyyy-MM-dd h:m:s.zzz",  # For milliseconds with space
            "dd/MM/yyyy h:m:s",
            "MM/dd/yyyy h:m:s",
            "dd-MM-yyyy h:m:s",
            "yyyy-MM-dd h:m",
            "dd/MM/yyyy h:m",
            "yyyy-MM-ddTh:m:s",
            "yyyy-MM-ddTh:m:s.zzz",
            "dd MMM yyyy h:m:s",
            "ddd MMM d h:m:s yyyy"
        ]
        
        for cFormat in aCustomFormats
            oTemp = new QDateTime()
            oTemp = oTemp.fromString(cDateTime, cFormat)
            
            if oTemp.isValid()
                @oQDateTime = oTemp
                return
            ok
        next
        
        StzRaise("Cannot parse date/time string: " + cDateTime)
    
	#--- EPOCH-BASED CREATION METHODS ---#
	
	def FromSecondsSinceEpoch(nSeconds)
	    return This.FromSecondsSinceEpochXT(nSeconds, :UnixStart)
	    
	    def FromSecondsSinceEpochXT(nSeconds, cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok

	        nBaseMs = This.GetOriginBase(cOrigin)
	        @oQDateTime.setMSecsSinceEpoch(nBaseMs + (nSeconds * 1000))
	    
	    def FromEpochSeconds(nSeconds)
	        return This.FromSecondsSinceEpoch(nSeconds)
	    
	    def FromUnixTimestamp(nSeconds)
	        return This.FromSecondsSinceEpoch(nSeconds)
	
	def FromMillisecondsSinceEpoch(nMilliseconds)
	    return This.FromMillisecondsSinceEpochXT(nMilliseconds, :UnixStart)
	    
	    def FromMillisecondsSinceEpochXT(nMilliseconds, cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nBaseMs = This.GetOriginBase(cOrigin)
	        @oQDateTime.setMSecsSinceEpoch(nBaseMs + nMilliseconds)
	    
	    def FromEpochMilliseconds(nMilliseconds)
	        return This.FromMillisecondsSinceEpoch(nMilliseconds)
	
	def FromMinutesSinceEpoch(nMinutes)
	    return This.FromMinutesSinceEpochXT(nMinutes, :UnixStart)
	    
	    def FromMinutesSinceEpochXT(nMinutes, cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nBaseMs = This.GetOriginBase(cOrigin)
	        @oQDateTime.setMSecsSinceEpoch(nBaseMs + (nMinutes * 60 * 1000))
	    
	    def FromEpochMinutes(nMinutes)
	        return This.FromMinutesSinceEpoch(nMinutes)
	
	def FromHoursSinceEpoch(nHours)
	    return This.FromHoursSinceEpochXT(nHours, :UnixStart)
	    
	    def FromHoursSinceEpochXT(nHours, cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nBaseMs = This.GetOriginBase(cOrigin)
	        @oQDateTime.setMSecsSinceEpoch(nBaseMs + (nHours * 3600 * 1000))
	    
	    def FromEpochHours(nHours)
	        return This.FromHoursSinceEpoch(nHours)
	
	def FromDaysSinceEpoch(nDays)
	    return This.FromDaysSinceEpochXT(nDays, :UnixStart)
	    
	    def FromDaysSinceEpochXT(nDays, cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nBaseMs = This.GetOriginBase(cOrigin)
	        @oQDateTime.setMSecsSinceEpoch(nBaseMs + (nDays * 86400 * 1000))
	    
	    def FromEpochDays(nDays)
	        return This.FromDaysSinceEpoch(nDays)
	
	def FromWeeksSinceEpoch(nWeeks)
	    return This.FromWeeksSinceEpochXT(nWeeks, :UnixStart)
	    
	    def FromWeeksSinceEpochXT(nWeeks, cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nBaseMs = This.GetOriginBase(cOrigin)
	        @oQDateTime.setMSecsSinceEpoch(nBaseMs + (nWeeks * 604800 * 1000))
	    
	    def FromEpochWeeks(nWeeks)
	        return This.FromWeeksSinceEpoch(nWeeks)
	
	def FromMonthsSinceEpoch(nMonths)
	    return This.FromMonthsSinceEpochXT(nMonths, :UnixStart)
	    
	    def FromMonthsSinceEpochXT(nMonths, cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nBaseMs = This.GetOriginBase(cOrigin)
	        nYears = floor(nMonths / 12)
	        nRemainingMonths = nMonths % 12
	        
	        _oDate_ = new QDate()
	        _oDate_.setDate(1970 + nYears, 1 + nRemainingMonths, 1)
	        _oTime_ = new QTime()
	        _oTime_.setHMS(0, 0, 0, 0)
	        
	        @oQDateTime.setDate(_oDate_)
	        @oQDateTime.setTime(_oTime_)
	        @oQDateTime = @oQDateTime.addMSecs(nBaseMs)  # Adjust for origin
	    
	    def FromEpochMonths(nMonths)
	        return This.FromMonthsSinceEpoch(nMonths)
	
	def FromYearsSinceEpoch(nYears)
	    return This.FromYearsSinceEpochXT(nYears, :UnixStart)
	    
	    def FromYearsSinceEpochXT(nYears, cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nBaseMs = This.GetOriginBase(cOrigin)
	        _oDate_ = new QDate()
	        _oDate_.setDate(1970 + nYears, 1, 1)
	        _oTime_ = new QTime()
	        _oTime_.setHMS(0, 0, 0, 0)
	        
	        @oQDateTime.setDate(_oDate_)
	        @oQDateTime.setTime(_oTime_)
	        @oQDateTime = @oQDateTime.addMSecs(nBaseMs)  # Adjust for origin
	    
	    def FromEpochYears(nYears)
	        return This.FromYearsSinceEpoch(nYears)

	#--- NATURAL LANGUAGE EPOCH CREATION ---#
	
	def FromNaturalEpoch(cNatural)
	    return This.FromNaturalEpochXT(cNatural, :UnixStart)
	    
	    def FromNaturalEpochXT(cNatural, cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nDurationMs = This.ParseNaturalDuration(cNatural)
	        nBaseMs = This.GetOriginBase(cOrigin)
	        @oQDateTime.setMSecsSinceEpoch(nBaseMs + nDurationMs)
	    
	    def FromNaturalSinceEpoch(cNatural)
	        return This.FromNaturalEpoch(cNatural)
	
	#--- COMBINED EPOCH CREATION WITH HASH ---#
	
	def FromEpochHash(aHash)
	    return This.FromEpochHashXT(aHash, :UnixStart)
	    
	    def FromEpochHashXT(aHash, cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nDurationMs = This.HashToMilliseconds(aHash)
	        nBaseMs = This.GetOriginBase(cOrigin)
	        @oQDateTime.setMSecsSinceEpoch(nBaseMs + nDurationMs)
	    
	    def FromEpochDuration(aHash)
	        return This.FromEpochHash(aHash)

    #--- COMPONENT EXTRACTION ---#
    
	def Date()
		acDateTime = @split(This.Content(), " ")
		return acDateTime[1]

    def DateQ()
        return new stzDate(This.Date())
    
	def Time()
		acDateTime = @split(This.Content(), " ")
		return acDateTime[2]

    def TimeQ()
        return new stzTime(This.Time())
    
    #--- ARITHMETIC OPERATIONS ---#
    
    def AddDays(nDays)
        @oQDateTime = @oQDateTime.addDays(nDays)
        return This.ToString()
    
    def AddDaysQ(nDays)
        This.AddDays(nDays)
        return This
    
    def AddMonths(nMonths)
        @oQDateTime = @oQDateTime.addMonths(nMonths)
        return This.ToString()
    
    def AddMonthsQ(nMonths)
        This.AddMonths(nMonths)
        return This
    
    def AddYears(nYears)
        @oQDateTime = @oQDateTime.addYears(nYears)
        return This.ToString()
    
    def AddYearsQ(nYears)
        This.AddYears(nYears)
        return This
    
    def AddSeconds(nSeconds)
        @oQDateTime = @oQDateTime.addSecs(nSeconds)
        return This.ToString()
    
    def AddSecondsQ(nSeconds)
        This.AddSeconds(nSeconds)
        return This
    
    def AddMinutes(nMinutes)
        @oQDateTime = @oQDateTime.addSecs(nMinutes * 60)
        return This.ToString()
    
    def AddMinutesQ(nMinutes)
        This.AddMinutes(nMinutes)
        return This
    
    def AddHours(nHours)
        @oQDateTime = @oQDateTime.addSecs(nHours * 3600)
        return This.ToString()
    
    def AddHoursQ(nHours)
        This.AddHours(nHours)
        return This
    
    def AddMilliseconds(nMs)
        @oQDateTime = @oQDateTime.addMSecs(nMs)
        return This.ToStringXT("yyyy-MM-dd hh:mm:ss.zzz")
    
    def AddMillisecondsQ(nMs)
        This.AddMilliseconds(nMs)
        return This

    def SubtractDays(nDays)
        @oQDateTime = @oQDateTime.addDays(-nDays)
        return This.ToString()
    
    def SubtractDaysQ(nDays)
        This.SubtractDays(nDays)
        return This

    def SubtractMonths(nMonths)
        @oQDateTime = @oQDateTime.addMonths(-nMonths)
        return This.ToString()
    
    def SubtractMonthsQ(nMonths)
        This.SubtractMonths(nMonths)
        return This

    def SubtractYears(nYears)
        @oQDateTime = @oQDateTime.addYears(-nYears)
        return This.ToString()
    
    def SubtractYearsQ(nYears)
        This.SubtractYears(nYears)
        return This

    def SubtractSeconds(nSeconds)
        @oQDateTime = @oQDateTime.addSecs(-nSeconds)
        return This.ToString()
    
    def SubtractSecondsQ(nSeconds)
        This.SubtractSeconds(nSeconds)
        return This

    def SubtractMilliSeconds(nMilliSeconds)
        @oQDateTime = @oQDateTime.addMSecs(-nMilliSeconds)
        return This.ToStringXT("yyyy-mm-dd hh:mm:ss.zzz")
    
    def SubtractMilliSecondsQ(nMilliSeconds)
        This.SubtractMilliSeconds(nMilliSeconds)
        return This

    #--- COMPARISON OPERATIONS ---#

    def IsBefore(poOtherDateTime)
        if isString(poOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(poOtherDateTime)
        else
            _oOtherDateTime_ = poOtherDateTime
        ok

        return @oQDateTime < _oOtherDateTime_.QDateTimeObject()

    def IsAfter(poOtherDateTime)
        if isString(poOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(poOtherDateTime)
        else
            _oOtherDateTime_ = poOtherDateTime
        ok

        return @oQDateTime > _oOtherDateTime_.QDateTimeObject()

    def IsEqual(poOtherDateTime)
        if isString(poOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(poOtherDateTime)
        else
            _oOtherDateTime_ = poOtherDateTime
        ok

        return @oQDateTime = _oOtherDateTime_.QDateTimeObject()

    def IsBetween(poStartDateTime, poEndDateTime)
        if isString(poStartDateTime)
            _oStartDateTime_ = new stzDateTime(poStartDateTime)
        else
            _oStartDateTime_ = poStartDateTime
        ok

        if isString(poEndDateTime)
            _oEndDateTime_ = new stzDateTime(poEndDateTime)
        else
            _oEndDateTime_ = poEndDateTime
        ok
        
        return This.IsAfter(_oStartDateTime_) and This.IsBefore(_oEndDateTime_)

    def IsNow()
        _oNow_ = new QDateTime()
        _oNow_ = _oNow_.currentDateTime()
        nDiff = abs(@oQDateTime.secsTo(_oNow_))
        return nDiff < 60  # Within 1 minute

    def IsToday()
        return This.DateQ().IsToday()

    def IsTomorrow()
        return This.DateQ().IsTomorrow()

    def IsYesterday()
        return This.DateQ().IsYesterday()

	#--- EPOCH CONVERSIONS ---#

	def ToSecondsSinceEpoch()
	    return This.ToSecondsSinceEpochXT(:UnixStart)
	    
	    def ToSecondsSinceEpochXT(cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nCurrentMs = @oQDateTime.toMSecsSinceEpoch()
	        nOriginMs = This.GetOriginBase(cOrigin)
	        return floor((nCurrentMs - nOriginMs) / 1000)
	
	    def ToEpochSeconds()
	        return This.ToSecondsSinceEpoch()
	
	    def ToUnixTimestamp()
	        return This.ToSecondsSinceEpoch()
	
	def ToMillisecondsSinceEpoch()
	    return This.ToMillisecondsSinceEpochXT(:UnixStart)
	    
	    def ToMillisecondsSinceEpochXT(cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        nCurrentMs = @oQDateTime.toMSecsSinceEpoch()
	        nOriginMs = This.GetOriginBase(cOrigin)
	        return nCurrentMs - nOriginMs
	
	    def ToEpochMilliseconds()
	        return This.ToMillisecondsSinceEpoch()
	
	    def ToUnixTimestampMs()
	        return This.ToMillisecondsSinceEpoch()
	
	def ToMinutesSinceEpoch()
	    return This.ToMinutesSinceEpochXT(:UnixStart)
	    
	    def ToMinutesSinceEpochXT(cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        return floor(This.ToSecondsSinceEpochXT(cOrigin) / 60)
	
	    def ToEpochMinutes()
	        return This.ToMinutesSinceEpoch()
	
	def ToHoursSinceEpoch()
	    return This.ToHoursSinceEpochXT(:UnixStart)
	    
	    def ToHoursSinceEpochXT(cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        return floor(This.ToSecondsSinceEpochXT(cOrigin) / 3600)
	
	    def ToEpochHours()
	        return This.ToHoursSinceEpoch()
	
	def ToDaysSinceEpoch()
	    return This.ToDaysSinceEpochXT(:UnixStart)
	    
	    def ToDaysSinceEpochXT(cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        return floor(This.ToSecondsSinceEpochXT(cOrigin) / 86400)
	
	    def ToEpochDays()
	        return This.ToDaysSinceEpoch()
	
	def ToWeeksSinceEpoch()
	    return This.ToWeeksSinceEpochXT(:UnixStart)
	    
	    def ToWeeksSinceEpochXT(cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        return floor(This.ToSecondsSinceEpochXT(cOrigin) / 604800)
	
	    def ToEpochWeeks()
	        return This.ToWeeksSinceEpoch()
    
	def ToMonthsSinceEpoch()
	    return This.ToMonthsSinceEpochXT(:UnixStart)
	    
	    def ToMonthsSinceEpochXT(cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        oOrigin = new QDateTime()
	        oOrigin.setMSecsSinceEpoch(This.GetOriginBase(cOrigin))
	        
	        nYears = @oQDateTime.date().year() - oOrigin.date().year()
	        nMonths = @oQDateTime.date().month() - oOrigin.date().month()
	        
	        return (nYears * 12) + nMonths
	
		def ToEpochMonths()
			return This.ToMonthsSinceEpoch()
	
	def ToYearsSinceEpoch()
	    return This.ToYearsSinceEpochXT(:UnixStart)
	    
	    def ToYearsSinceEpochXT(cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        oOrigin = new QDateTime()
	        oOrigin.setMSecsSinceEpoch(This.GetOriginBase(cOrigin))
	        
	        nYears = @oQDateTime.date().year() - oOrigin.date().year()
	        
	        # Adjust if we haven't reached the anniversary date this year
	        if @oQDateTime.date().month() < oOrigin.date().month() or 
	           (@oQDateTime.date().month() = oOrigin.date().month() and @oQDateTime.date().day() < oOrigin.date().day())
	            nYears--
	        ok
	        
	        return nYears
	
		def ToEpochYears()
			return This.ToYearsSinceEpoch()
	
	def ToDecadesSinceEpoch()
	    return This.ToDecadesSinceEpochXT(:UnixStart)
	    
	    def ToDecadesSinceEpochXT(cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        return floor(This.ToYearsSinceEpochXT(cOrigin) / 10)
	
		def ToEpochDecades()
			return This.ToDecadesSinceEpoch()
	
	def ToCenturiesSinceEpoch()
	    return This.ToCenturiesSinceEpochXT(:UnixStart)
	    
	    def ToCenturiesSinceEpochXT(cOrigin)
		if cOrigin = ""
			cOrigin = :UnixStart
		ok
	        return floor(This.ToYearsSinceEpochXT(cOrigin) / 100)
	
		def ToEpochCenturies()
			return This.ToCenturiesSinceEpoch()

    #--- TIME ZONE OPERATIONS ---#
    
    def ToUTCQ()
        oResult = @oQDateTime.toUTC()
        oNewDateTime = new stzDateTime("")
        oNewDateTime.SetQDateTime(oResult)
        return oNewDateTime

		def ToUTC()
			return This.ToUTCQ().Content()
    
    def ToLocalTimeQ()
        oResult = @oQDateTime.toLocalTime()
        oNewDateTime = new stzDateTime("")
        oNewDateTime.SetQDateTime(oResult)
        return oNewDateTime

		def ToLocalTime()
			return This.ToLocalTimeQ().Content()

    
	#--- TIME INFO

	def Year()
		return This.DateQ().Year()
	
		def YearN()
			return This.Year()
	
	def Month()
		return This.DateQ().Month()
	
		def MonthN()
			return This.DateQ().MonthN()

	def Day()
		return This.DateQ().Day()
	
		def DayN()
			return This.DateQ().DayN()

	def Hours()
		_cDateTimeStr_ = substr(This.ToString(), ".", ":")
		nResult = 0+ @split( @split(_cDateTimeStr_, " ")[2], ":")[1]
		return nResult

		def HoursN()
			return This.Hours()

	def Minutes()
		_cDateTimeStr_ = substr(This.ToString(), ".", ":")
		nResult = 0+ @split( @split(_cDateTimeStr_, " ")[2], ":")[2]
		return nResult
	
		def MinutesN()
			return This.Minutes()

	def Seconds()
		_cDateTimeStr_ = substr(This.ToString(), ".", ":")
		nResult = 0+ @split( @split(_cDateTimeStr_, " ")[2], ":")[3]
		return nResult
	
		def SecondsN()
			return This.Seconds()

	def MilliSeconds()

		nResult = 0
		_cDateTimeStr_ = substr(This.ToString(), ".", ":")
		_acParts_ = @split( @split(_cDateTimeStr_, " ")[2], ":")
		if len(_acParts_) = 4
			nResult = 0+ _acParts_[4]
		ok

		return nResult

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

	def ToStringXT(cFormat)
	    if NOT isString(cFormat)
	        StzRaise("Incorrect param type! cFormat must be a string.")
	    ok
	
	    # Handle empty format

	    if cFormat = ""
	        cFormat = $cDefaultDateTimeFormat
	        if @oQDateTime.time().msec() > 0
	            cFormat = "yyyy-MM-dd HH:mm:ss.zzz"
	        ok
	    ok
	    
		# Handle named patterns

		acNamedPatterns = [
			"simple", "simple12h", "simple24h",
			"long", "long12h", "long24h",
			"short", "short12h", "short24h",
			"medium", "medium12h", "medium24h",
		]

		if ring_find(acNamedPatterns, cFormat) > 0

		    # Handle special named formats with 24h/12h variants
		    # Simple formats (concise, user-friendly)
		    if cFormat = "simple" or cFormat = "simple12h"
		        return This.ToSimple()  # Default: 12-hour (dd/MM/yyyy h:mm AM/PM)
		    
		    but cFormat = "simple24h"
		        return @oQDateTime.toString("dd/MM/yyyy HH:mm")  # 15/03/2024 14:30
		    
		    # Long formats (verbose, fully spelled out)
		    but cFormat = "long" or cFormat = "long12h"
		        return This.ToLong()  # Default: 12-hour (dddd, MMMM d, yyyy h:mm:ss AM/PM)
		    
		    but cFormat = "long24h"
		        return @oQDateTime.toString("dddd, MMMM d, yyyy HH:mm:ss")  # Friday, March 15, 2024 14:30:45
		    
		    # Short formats (minimal, no year sometimes)
		    but cFormat = "short" or cFormat = "short12h"
		        nHour = This.Hours()
		        nHour12 = ConvertTo12Hour(nHour)
		        cAmPm = GetAmPmText(nHour)
		        return @oQDateTime.toString("dd/MM") + " " + nHour12 + ":" + 
		               Right("0" + This.Minutes(), 2) + " " + cAmPm  # 15/03 2:30 PM
		    
		    but cFormat = "short24h"
		        return @oQDateTime.toString("dd/MM HH:mm")  # 15/03 14:30
		    
		    # Medium formats (balanced detail)
		    but cFormat = "medium" or cFormat = "medium12h"
		        nHour = This.Hours()
		        nHour12 = ConvertTo12Hour(nHour)
		        cAmPm = GetAmPmText(nHour)
		        return @oQDateTime.toString("ddd, MMM d") + " " + nHour12 + ":" + 
		               Right("0" + This.Minutes(), 2) + " " + cAmPm  # Fri, Mar 15 2:30 PM
		    
		    but cFormat = "medium24h"
		        return @oQDateTime.toString("ddd, MMM d HH:mm")  # Fri, Mar 15 14:30
		    ok

	    ok

	    # Get actual Qt format string

	    cQtFormat = GetDateTimeFormat(cFormat)
	    
	    # Check if this is a 12-hour format that needs manual AM/PM handling
	    if substr(upper(cQtFormat), "AP") > 0
	        # Remove AP marker from format and format the datetime
	        cFormatWithout12h = substr(cQtFormat, "AP", "")
	        cFormatWithout12h = substr(cFormatWithout12h, "ap", "")
	        cFormatWithout12h = trim(cFormatWithout12h)
	        
	        # Replace HH with actual 12-hour value
	        nHour = This.Hours()
	        nHour12 = ConvertTo12Hour(nHour)
	        
	        # Replace hh in format with actual hour
	        cFormatFinal = substr(cFormatWithout12h, "hh", "" + nHour12)
	        if cFormatFinal = cFormatWithout12h
	            # Try single h
	            cFormatFinal = substr(cFormatWithout12h, "h", "" + nHour12)
	        ok
	        
	        cResult = @oQDateTime.toString(cFormatFinal)
	        cAmPm = GetAmPmText(nHour)
	        
	        return cResult + " " + cAmPm
	    else
	        # Standard 24-hour format
	        return @oQDateTime.toString(cQtFormat)
	    ok
	
	# Short formats

	def ToShort()
	    return This.ToStringXT(:Short)
	
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
	    return This.ToStringXT(:Medium)
	
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
	    return This.ToStringXT(:Compact)
	
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
	    return This.ToStringXT(:Standard)
	
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
	    return This.ToStringXT(:European)
	
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
	    return This.ToStringXT(:American)
	
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
	    return This.ToStringXT(:Iso12h)
	
		def ToIso12h()
			return This.ToStringXT(:Iso12h)

		def ToIsoAP()
		    return This.ToStringXT(:Iso12h)

		def ToIsoAmPm()
		    return This.ToStringXT(:Iso12h)

		def ToIsoWithAP()
		    return This.ToStringXT(:Iso12h)

		def ToIsoWithAmPm()
		    return This.ToStringXT(:Iso12h)
	
	def ToIso24h()
	    return This.ToStringXT(:Iso24h)
	    
		def ToIsoWithoutAP()
		    return This.ToStringXT(:Iso24h)

		def ToIsoWithoutAmPm()
		    return This.ToStringXT(:Iso24h)


	#--

	def ToISO8601()
	    return This.ToStringXT(:ISO8601)
	
	def ToISOWithMs()
	    return This.ToStringXT(:ISOWithMs)

	#--
	
	def ToVerbose()
	    return This.ToStringXT(:Verbose)
	
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
        return This.ToStringXT("dd MMM yyyy hh:mm:ss")

    def ToTextDate()
        return This.ToStringXT("ddd MMM d hh:mm:ss yyyy")

	def ToSimple()
	    oLocale = new stzLocale("")
	    nHour = This.Hours()
	    nHour12 = nHour % 12
	    if nHour12 = 0
	        nHour12 = 12
	    ok
	    
	    cResult = @oQDateTime.toString("dd/MM/yyyy") + " " + nHour12 + ":" + 
	              Right("0" + This.Minutes(), 2)
	    
	    if nHour >= 12
	        cResult += " " + oLocale.pmText()
	    else
	        cResult += " " + oLocale.amText()
	    ok
	    return cResult
	

		def ToSimple12h()
			return This.ToSimple()

		def ToSimple24h()
		    return This.ToStringXT(:Simple24h)

	def ToLong()
	    oLocale = new stzLocale("")
	    nHour = This.Hours()
	    nHour12 = nHour % 12
	    if nHour12 = 0
	        nHour12 = 12
	    ok
	    
	    cResult = @oQDateTime.toString("dddd, MMMM d, yyyy") + " " + nHour12 + ":" + 
	              Right("0" + This.Minutes(), 2) + ":" + 
	              Right("0" + This.Seconds(), 2)
	    
	    if nHour >= 12
	        cResult += " " + oLocale.pmText()
	    else
	        cResult += " " + oLocale.amText()
	    ok
	    return cResult

		def ToLong12h()
			return This.ToLong()

		def ToLong24h()
		    return This.ToStringXT(:Long24h)

	def ToLongDate()
		return This.ToStringXT(:LongDate)

	def ToString12h()
	    nHour = This.Hours()
	    nHour12 = ConvertTo12Hour(nHour)
	    cAmPm = GetAmPmText(nHour)
	    
	    return @oQDateTime.toString("yyyy-MM-dd") + " " + nHour12 + ":" +
	           Right("0" + This.Minutes(), 2) + ":" +
	           Right("0" + This.Seconds(), 2) + " " + cAmPm

    #--- HUMAN-READABLE ---#

    def ToHuman()
		cDateHuman = This.DateQ().ToHuman()
        cTimeHuman = This.TimeQ().ToHuman()
        
        return cDateHuman + " at " + cTimeHuman

    def ToRelative()
        oNow = new stzDateTime("")

		nYears = This.Years()
		nMonths = This.Months()
		nWeeks = This.Weeks()
		nDays = This.Days()

		nHours = This.Hours()
		nMinutes = This.Minutes()
        nSeconds = This.Seconds()
        nMilliSeconds = This.MSeconds()

        if abs(nSecs) < 60
            return "just now"
        
        but nSecs < 0  # In the past
            nAbsSecs = -nSecs
            
            if nAbsSecs < 3600
                return '' + nMinutes + " minute" + Iff(nMins=1, "", "s") + " ago"

            but nAbsSecs < 86400
                return '' + nHours + " hour" + Iff(nHours=1, "", "s") + " ago"

            but nAbsSecs < 604800  # Less than a week
                return '' + nDays + " day" + Iff(nDays=1, "", "s") + " ago"

            but nAbsSecs < 2592000  # Less than 30 days
                nWeeks = floor(nAbsSecs / 604800)
                return '' + nWeeks + " week" + Iff(nWeeks=1, "", "s") + " ago"

            but nAbsSecs < 31536000  # Less than a year
                return '' + nMonths + " month" + Iff(nMonths=1, "", "s") + " ago"

            else
                return '' + nYears + " year" + Iff(nYears=1, "", "s") + " ago"
            ok
        
        else  # In the future
            if nSeconds < 3600
                return "in " + nMinutes + " minute" + Iff(nMinutes=1, "", "s")

            but nSeconds < 86400
                return "in " + nHours + " hour" + Iff(nHours=1, "", "s")

            but nSeconds < 604800
                return "in " + nDays + " day" + Iff(nDays=1, "", "s")

            but nSecs < 2592000
                return "in " + nWeeks + " week" + Iff(nWeeks=1, "", "s")

            but nSecs < 31536000
                return "in " + nMonths + " month" + Iff(nMonths=1, "", "s")

            else
                return "in " + nYears + " year" + Iff(nYears=1, "", "s")
            ok
        ok

    #--- UTILITY METHODS ---#

    def Copy()
        oNewDateTime = new stzDateTime("")
        oNewDateTime.SetQDateTime(new QDateTime())
        oNewDateTime.QDateTimeObject().setDate(This.Date())
        oNewDateTime.QDateTimeObject().setTime(This.Time())
        return oNewDateTime
    
    def SetQDateTime(oNewQDateTime)
        @oQDateTime = oNewQDateTime
        return This

    def SetQDateTimeQ(oNewQDateTime)
        This.SetQDateTime(oNewQDateTime)
        return This
    
    def QDateTimeObject()
        return @oQDateTime
    
    def IsValid()
        if @oQDateTime.isValid()
            return TRUE
        else
            return FALSE
        ok
    
    def IsAStzDateTime()
        return TRUE

	def IsNaturalEpochString(cStr)
	    # Must contain "from epoch" phrase
	    cLower = lower(cStr)
	    
	    if substr(cLower, "from epoch") > 0 or 
	       substr(cLower, "since epoch") > 0
	        return TRUE
	    ok
	    
	    return FALSE
	
	def ParseNaturalEpoch(cNatural)
	    # Parse natural language like "5 days 3 hours 20 minutes"
	    # or "2 years 6 months 15 days" since epoch
	    
	    nTotalMilliseconds = 0
	    
	    # Convert to lowercase for case-insensitive matching
	    cNatural = lower(cNatural)
	    
	    # Remove "from epoch" or "since epoch" phrase
	    cNatural = substr(cNatural, "from epoch", "")
	    cNatural = substr(cNatural, "since epoch", "")
	    cNatural = trim(cNatural)
	    
	    # Extract and sum all time units
	    aUnits = [
	        [:years, 31536000000],      # 365 days in ms
	        [:year, 31536000000],
	        [:months, 2628000000],      # 30.42 days in ms (average)
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
	    
	    for aUnit in aUnits
	        cUnit = aUnit[1]
	        nMultiplier = aUnit[2]
	        
	        # Match pattern: number followed by unit
	        # e.g., "5 days" or "3.5 hours"
	        cPattern = "(\d+\.?\d*)\s*" + cUnit
	        
	        # Simple extraction (in real implementation, use regex)
	        nPos = substr(cNatural, cUnit)
	        if nPos > 0
	            # Extract number before unit
	            cBefore = left(cNatural, nPos - 1)
	            cBefore = trim(cBefore)
	            
	            # Get last token (the number)
	            aTokens = split(cBefore, " ")
	            if len(aTokens) > 0
	                cNumber = aTokens[len(aTokens)]
	                nValue = 0+ cNumber
	                nTotalMilliseconds += (nValue * nMultiplier)
	            ok
	        ok
	    next
	    
	    @oQDateTime.setMSecsSinceEpoch(nTotalMilliseconds)
	
	def SetFromEpochMonths(nMonths)
	    nYears = floor(nMonths / 12)
	    nRemainingMonths = nMonths % 12
	    
	    _oDate_ = new QDate()
	    _oDate_.setDate(1970 + nYears, 1 + nRemainingMonths, 1)
	    _oTime_ = new QTime()
	    _oTime_.setHMS(0, 0, 0, 0)
	    
	    @oQDateTime.setDate(_oDate_)
	    @oQDateTime.setTime(_oTime_)
	
	def SetFromEpochYears(nYears)
	    _oDate_ = new QDate()
	    _oDate_.setDate(1970 + nYears, 1, 1)
	    _oTime_ = new QTime()
	    _oTime_.setHMS(0, 0, 0, 0)
	    
	    @oQDateTime.setDate(_oDate_)
	    @oQDateTime.setTime(_oTime_)
	
	def SetFromEpochDuration(aHash)
	    # Hash like [:Years = 54, :Months = 3, :Days = 15, :Hours = 10]
	    nTotalMs = 0
	    
	    if aHash[:Years] != NULL
	        nTotalMs += (aHash[:Years] * 31536000000)
	    ok
	    if aHash[:Months] != NULL
	        nTotalMs += (aHash[:Months] * 2628000000)
	    ok
	    if aHash[:Weeks] != NULL
	        nTotalMs += (aHash[:Weeks] * 604800000)
	    ok
	    if aHash[:Days] != NULL
	        nTotalMs += (aHash[:Days] * 86400000)
	    ok
	    if aHash[:Hours] != NULL
	        nTotalMs += (aHash[:Hours] * 3600000)
	    ok
	    if aHash[:Minutes] != NULL
	        nTotalMs += (aHash[:Minutes] * 60000)
	    ok
	    if aHash[:Seconds] != NULL
	        nTotalMs += (aHash[:Seconds] * 1000)
	    ok
	    if aHash[:Milliseconds] != NULL
	        nTotalMs += aHash[:Milliseconds]
	    ok
	    
	    @oQDateTime.setMSecsSinceEpoch(nTotalMs)

    #--- HELPER METHODS FOR COUNTINGFROM ---#

    def IsCountingFromString(cStr)
        cLower = lower(cStr)
        return (substr(cLower, "counting from") > 0) or
		(substr(cLower, "starting from") > 0) or
		(substr(cLower, "since") > 0)

    def ParseCountingFrom(cStr)
        # "5 years 3 months counting from space age"
        cLower = lower(cStr)

        nPos = substr(cLower, "counting from")
        if nPos = 0
		nPos = substr(cLower, "starting from")
	ok

	if nPos = 0
		nPos = substr(cLower, "since")
	ok

        if nPos > 0
            cDuration = substr(cStr, 1, nPos - 1)
            cOrigin = substr(cStr, nPos + 13, len(cStr))
            cOrigin = trim(cOrigin)
            
            # Map natural names to origin keys
            cOriginKey = This.MapOriginName(cOrigin)
            This.SetFromNaturalDuration(cDuration, cOriginKey)
        ok

    def MapOriginName(cName)
        cLower = lower(trim(cName))
        
        if substr(cLower, "unix") > 0
            return :UnixStart

        but substr(cLower, "year one") > 0 or substr(cLower, "common era") > 0
            return :YearOne

        but substr(cLower, "islamic") > 0
            return :IslamicCalendar

        but substr(cLower, "space age") > 0
            return :SpaceAge

        but substr(cLower, "atomic age") > 0
            return :AtomicAge

        but substr(cLower, "us independence") > 0
            return :USIndependence

        but substr(cLower, "french revolution") > 0
            return :FrenchRevolution

        but substr(cLower, "internet") > 0
            return :InternetAge

        else
            return :UnixStart
        ok

    def SetCountingFrom(nValue, cOrigin)
	if cOrigin = ""
		cOrigin = :UnixStart
	ok
        # Get origin base time
        nBaseMs = This.GetOriginBase(cOrigin)
        
        # If nValue is a hash, parse it
        if isList(nValue) and IsHashList(nValue)
            nDurationMs = This.HashToMilliseconds(nValue)
            @oQDateTime.setMSecsSinceEpoch(nBaseMs + nDurationMs)
        else
            # Assume seconds
            @oQDateTime.setMSecsSinceEpoch(nBaseMs + (nValue * 1000))
        ok

    def GetOriginBase(cOrigin)
        for aOrigin in aTimeOrigins
            if aOrigin[1] = cOrigin
                return aOrigin[2]
            ok
        next
        return 0  # Default to UnixStart

    def SetFromNaturalDuration(cDuration, cOrigin)
	if cOrigin = ""
		cOrigin = :UnixStart
	ok
        nDurationMs = This.ParseNaturalDuration(cDuration)
        nBaseMs = This.GetOriginBase(cOrigin)
        @oQDateTime.setMSecsSinceEpoch(nBaseMs + nDurationMs)

    def ParseNaturalDuration(cDuration)
        # Parse "5 years 3 months 20 days" into milliseconds
        nTotalMs = 0
        cDuration = lower(trim(cDuration))
        
        aUnits = [
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
        
        aTokens = split(cDuration, " ")
        
        for aUnit in aUnits
            cUnit = aUnit[1]
            nMultiplier = aUnit[2]
            
            for i = 1 to len(aTokens)
                if lower(aTokens[i]) = cUnit and i > 1
                    nValue = 0+ aTokens[i-1]
                    nTotalMs += (nValue * nMultiplier)
                    exit
                ok
            next
        next
        
        return nTotalMs

    def HashToMilliseconds(aHash)
        nMs = 0
        
        if aHash[:Years] != NULL
            nMs += (aHash[:Years] * 31536000000)
        ok
        if aHash[:Months] != NULL
            nMs += (aHash[:Months] * 2628000000)
        ok
        if aHash[:Weeks] != NULL
            nMs += (aHash[:Weeks] * 604800000)
        ok
        if aHash[:Days] != NULL
            nMs += (aHash[:Days] * 86400000)
        ok
        if aHash[:Hours] != NULL
            nMs += (aHash[:Hours] * 3600000)
        ok
        if aHash[:Minutes] != NULL
            nMs += (aHash[:Minutes] * 60000)
        ok
        if aHash[:Seconds] != NULL
            nMs += (aHash[:Seconds] * 1000)
        ok
        
        return nMs

    #--- PUBLIC QUERY METHODS ---#

    def MillisecondsCountingFromUnixStart()
        return This.ToMillisecondsSinceEpochXT(:UnixStart)

	def MillisecondsSinceUnixStart()
		return This.MillisecondsCountingFromUnixStart()

	def MillisecondsStartingFromUnixStart()
		return This.MillisecondsCountingFromUnixStart()

	#--

	def DurationInMillisecondsCountingFromUnixStart()
		return This.ToMillisecondsSinceEpochXT(:UnixStart)

	def DurationInMillisecondsStartingFromUnixStart()
		return This.ToMillisecondsSinceEpochXT(:UnixStart)

	def DurationInMillisecondsSinceUnixStart()
		return This.ToMillisecondsSinceEpochXT(:UnixStart)

	def DurationInMSecondsCountingFromUnixStart()
		return This.ToMillisecondsSinceEpochXT(:UnixStart)

	def DurationInMSecondsStartingFromUnixStart()
		return This.ToMillisecondsSinceEpochXT(:UnixStart)

	def DurationInMSecondsSinceUnixStart()
		return This.ToMillisecondsSinceEpochXT(:UnixStart)

    def SecondsCountingFromUnixStart()
        return This.ToSecondsSinceEpochXT(:UnixStart)

	    def SecondsSinceUnixStart()
	        return This.ToSecondsSinceEpochXT(:UnixStart)

	    def SecondsStartingFromUnixStart()
	        return This.ToSecondsSinceEpochXT(:UnixStart)

		#--

		def DurationInSecondsCountingFromUnixStart()
			 return This.ToSecondsSinceEpochXT(:UnixStart)

		def DurationInSecondsStartingFromUnixStart()
			 return This.ToSecondsSinceEpochXT(:UnixStart)

		def DurationInSecondsSinceUnixStart()
			 return This.ToSecondsSinceEpochXT(:UnixStart)

    def CountingFromXT()
        # Extended information about time from Unix start
        nMs = This.ToMillisecondsSinceEpochXT(:UnixStart)
        
        return [
            :Milliseconds = nMs,
            :Seconds = floor(nMs / 1000),
            :Minutes = floor(nMs / 60000),
            :Hours = floor(nMs / 3600000),
            :Days = floor(nMs / 86400000),
            :Weeks = floor(nMs / 604800000),
            :Years = floor(nMs / 31536000000)
        ]

/*

    def CountingFromInMilliSeconds()
	return This.CountingFromXT()[:MilliSeconds]

    def CountingFromInSeconds()
	return This.CountingFromXT()[:Seconds]

    def CountingFromInMinutes()
	return This.CountingFromXT()[:Minutes]

    def CountingFromInHours()
	return This.CountingFromXT()[:Hours]

    def CountingFromInDays()
	return This.CountingFromXT()[:Days]

    def CountingFromInWeeks()
	return This.CountingFromXT()[:Weeks]

    def CountingFromInYears()
	return This.CountingFromXT()[:Years]
*/

    def CountingInMilliSeconds(cOrigin)
	if isList(cOrigin) and StzListQ(cOrigin).IsFromOrSinceOrStartingFrom()
		cOrigin = cOrigin[2]
	ok

	return This.CountingInMilliSecondsFrom(cOrigin)

	def DurationInMilliSeconds(cOrigin)
		return This.CountingInMilliSecondsFrom(cOrigin)

	def CountingInMSecondsFrom(cOrigin)
		return This.CountingInMilliSecondsFrom(cOrigin)

	def DurationInMSeconds(cOrigin)
		return This.CountingInMilliSecondsFrom(cOrigin)

    def CountingInMillisecondsFrom(cOrigin)
        # Get milliseconds from specified origin
        nCurrentMs = @oQDateTime.toMSecsSinceEpoch()
        nOriginMs = This.GetOriginBase(cOrigin)
        return nCurrentMs - nOriginMs

	def CountingInMillisecondsSince(cOrigin)
		return This.CountingInMillisecondsFrom(cOrigin)

	def CountingInMillisecondsStartingFrom(cOrigin)
		return This.CountingInMillisecondsFrom(cOrigin)

	def DurationInMillisecondsFrom(cOrigin)
		return This.CountingInMillisecondsFrom(cOrigin)

	def DurationInMillisecondsStartingFrom(cOrigin)
		return This.CountingInMillisecondsFrom(cOrigin)

	def DurationInMillisecondsSince(cOrigin)
		return This.CountingInMillisecondsFrom(cOrigin)

	#--

	def CountingInMSecondsSince(cOrigin)
		return This.CountingInMillisecondsFrom(cOrigin)

	def CountingInMsecondsStartingFrom(cOrigin)
		return This.CountingInMillisecondsFrom(cOrigin)

	def DurationInMSecondsFrom(cOrigin)
		return This.CountingInMillisecondsFrom(cOrigin)

	def DurationInMSecondsStartingFrom(cOrigin)
		return This.CountingInMillisecondsFrom(cOrigin)

	def DurationInMSecondsSince(cOrigin)
		return This.CountingInMillisecondsFrom(cOrigin)

    #--

    def CountingInSeconds(cOrigin)
	if isList(cOrigin) and StzListQ(cOrigin).IsFromOrSinceOrStartingFrom()
		cOrigin = cOrigin[2]
	ok

	return This.CountingInSecondsFrom(cOrigin)

	def DurationInSeconds(cOrigin)
		return This.CountingInSecondsFrom(cOrigin)

    def CountingFrom(cOrigin)
        # Get seconds from specified origin
        nCurrentMs = @oQDateTime.toMSecsSinceEpoch()
        nOriginMs = This.GetOriginBase(cOrigin)
        return (nCurrentMs - nOriginMs) / 1000

	def CountingInSecondsFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def CountingInSecondsSince(cOrigin)
		return This.CountingFrom(cOrigin)

	def CountingInSecondsStartingFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationStartingFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationSince(cOrigin)
		return This.CountingFrom(cOrigin)

    #--

    def CountingInMinutes(cOrigin)
	if isList(cOrigin) and StzListQ(cOrigin).IsFromOrSinceOrStartingFrom()
		cOrigin = cOrigin[2]
	ok

	return This.CountingInMinutesFrom(cOrigin)

	def DurationInMinutes(cOrigin)
		return This.CountingInMinutesFrom(cOrigin)

    def CountingInMinutesFrom(cOrigin)
        # Get seconds from specified origin
        nCurrentMs = @oQDateTime.toMSecsSinceEpoch()
        nOriginMs = This.GetOriginBase(cOrigin)
        return (nCurrentMs - nOriginMs) / (1000 * 60)

	def CountingInMinutesSince(cOrigin)
		return This.CountingFrom(cOrigin)

	def CountingInMinutesStartingFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationInMinutesFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationInMinutesStartingFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationInMinutesSince(cOrigin)
		return This.CountingFrom(cOrigin)

    #--

    def CountingInHours(cOrigin)
	if isList(cOrigin) and StzListQ(cOrigin).IsFromOrSinceOrStartingFrom()
		cOrigin = cOrigin[2]
	ok

	return This.CountingInHoursFrom(cOrigin)

	def DurationInHours(cOrigin)
		return This.CountingInHoursFrom(cOrigin)

    def CountingInHoursFrom(cOrigin)
        # Get seconds from specified origin
        nCurrentMs = @oQDateTime.toMSecsSinceEpoch()
        nOriginMs = This.GetOriginBase(cOrigin)
        return (nCurrentMs - nOriginMs) / (1000 * 60 * 60)

	def CountingInHoursSince(cOrigin)
		return This.CountingFrom(cOrigin)

	def CountingInHoursStartingFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationInHoursFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationInHoursStartingFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationInHoursSince(cOrigin)
		return This.CountingFrom(cOrigin)

    #--

    def CountingInDays(cOrigin)
	if isList(cOrigin) and StzListQ(cOrigin).IsFromOrSinceOrStartingFrom()
		cOrigin = cOrigin[2]
	ok

	return This.CountingInDaysFrom(cOrigin)

	def DurationInDays(cOrigin)
		return This.CountingInDaysFrom(cOrigin)

    def CountingInDaysFrom(cOrigin)
        # Get seconds from specified origin
        nCurrentMs = @oQDateTime.toMSecsSinceEpoch()
        nOriginMs = This.GetOriginBase(cOrigin)
        return (nCurrentMs - nOriginMs) / (1000 * 60 * 60 * 60)

	def CountingInDaysSince(cOrigin)
		return This.CountingFrom(cOrigin)

	def CountingInDaysStartingFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationInDaysFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationInDaysStartingFrom(cOrigin)
		return This.CountingFrom(cOrigin)

	def DurationInDaysSince(cOrigin)
		return This.CountingFrom(cOrigin)

   #===

    def SetFromHash(aHash)
        # Placeholder for original standard hash setting if needed
        # Already handled in init, but can be called separately
        nYear = 2000
        nMonth = 1
        nDay = 1
        nHour = 0
        nMinute = 0
        nSecond = 0
        
        if aHash[:Year] != NULL
            nYear = 0+ aHash[:Year]
        ok
        if aHash[:Month] != NULL
            nMonth = 0+ aHash[:Month]
        ok
        if aHash[:Day] != NULL
            nDay = 0+ aHash[:Day]
        ok
        if aHash[:Hour] != NULL
            nHour = 0+ aHash[:Hour]
        ok
        if aHash[:Minute] != NULL
            nMinute = 0+ aHash[:Minute]
        ok
        if aHash[:Second] != NULL
            nSecond = 0+ aHash[:Second]
        ok
        
        _oDate_ = new QDate()
        _oDate_.setDate(nYear, nMonth, nDay)
        _oTime_ = new QTime()
        _oTime_.setHMS(nHour, nMinute, nSecond, 0)
        
        @oQDateTime.setDate(_oDate_)
        @oQDateTime.setTime(_oTime_)

