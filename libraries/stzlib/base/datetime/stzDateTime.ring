
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
    [ :ISOMinute,     "yyyy-MM-dd HH:mm" ],         # 2024-03-15 14:30
    [ :ISOWithMs,     "yyyy-MM-dd HH:mm:ss.zzz" ],  # 2024-03-15 14:30:45.123
    [ :ISO8601,       "yyyy-MM-ddTHH:mm:ss" ],      # 2024-03-15T14:30:45
    [ :ISO8601Ms,     "yyyy-MM-ddTHH:mm:ss.zzz" ],  # 2024-03-15T14:30:45.123
    
    [ :ISO12h,        "yyyy-MM-dd hh:mm:ss AP" ],   # 2024-03-15 02:30:45 PM
    [ :ISO12hMinute,  "yyyy-MM-dd hh:mm AP" ],      # 2024-03-15 02:30 PM
    
    # ===== COMPACT FORMATS (24-hour) =====
    # Short, efficient formats for logs and displays
    
    [ :Compact,       "yyyy-MM-dd HH:mm" ],         # 2024-03-15 14:30
    [ :CompactSec,    "yyyy-MM-dd HH:mm:ss" ],      # 2024-03-15 14:30:45
    [ :CompactMs,     "yyyy-MM-dd HH:mm:ss.zzz" ],  # 2024-03-15 14:30:45.123
    
    [ :Compact12h,    "yyyy-MM-dd hh:mm AP" ],      # 2024-03-15 02:30 PM
    [ :Compact12hSec, "yyyy-MM-dd hh:mm:ss AP" ],   # 2024-03-15 02:30:45 PM
    
    # ===== STANDARD FORMATS (24-hour, Region-aware) =====
    # Common readable formats with slashes
    
    [ :Standard,      "dd/MM/yyyy HH:mm:ss" ],      # 15/03/2024 14:30:45
    [ :StandardMinute,"dd/MM/yyyy HH:mm" ],         # 15/03/2024 14:30
    [ :European,      "dd/MM/yyyy HH:mm:ss" ],      # 15/03/2024 14:30:45 (same as Standard)
    [ :American,      "MM/dd/yyyy HH:mm:ss" ],      # 03/15/2024 14:30:45
    
    [ :Standard12h,   "dd/MM/yyyy hh:mm:ss AP" ],   # 15/03/2024 02:30:45 PM
    [ :Standard12hMin,"dd/MM/yyyy hh:mm AP" ],      # 15/03/2024 02:30 PM
    [ :European12h,   "dd/MM/yyyy hh:mm:ss AP" ],   # 15/03/2024 02:30:45 PM
    [ :American12h,   "MM/dd/yyyy hh:mm:ss AP" ],   # 03/15/2024 02:30:45 PM
    
    # ===== VERBOSE FORMATS (Human-readable) =====
    # Full text representations
    
    [ :Verbose,       "dddd, MMMM d, yyyy HH:mm:ss" ],     # Friday, March 15, 2024 14:30:45
    [ :VerboseMinute, "dddd, MMMM d, yyyy HH:mm" ],        # Friday, March 15, 2024 14:30
    [ :LongDate,      "dddd, MMMM d, yyyy" ],              # Friday, March 15, 2024
    
    [ :Verbose12h,    "dddd, MMMM d, yyyy hh:mm:ss AP" ],  # Friday, March 15, 2024 02:30:45 PM
    [ :Verbose12hMin, "dddd, MMMM d, yyyy hh:mm AP" ],     # Friday, March 15, 2024 02:30 PM
    
    # ===== SPECIAL FORMATS =====
    # Specific use cases
    
    [ :RFC2822,       "dd MMM yyyy HH:mm:ss" ],     # 15 Mar 2024 14:30:45
    [ :RFC282212h,    "dd MMM yyyy hh:mm:ss AP" ],  # 15 Mar 2024 02:30:45 PM
    [ :UnixLog,       "MMM d HH:mm:ss" ],           # Mar 15 14:30:45
    [ :ShortText,     "ddd MMM d HH:mm:ss yyyy" ],  # Fri Mar 15 14:30:45 2024
    [ :ShortText12h,  "ddd MMM d hh:mm:ss AP yyyy" ] # Fri Mar 15 02:30:45 PM 2024

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
    oQDateTime
    
    def init(pDateTime)
        oQDateTime = new QDateTime()
        
        if IsNull(pDateTime) or pDateTime = ""
            oQDateTime = oQDateTime.currentDateTime()
            
        but isString(pDateTime)
            This.ParseStringDateTime(pDateTime)
            
        but isNumber(pDateTime)
            # Unix timestamp
            oQDateTime.setMSecsSinceEpoch(pDateTime * 1000)
            
        but isList(pDateTime)
            if len(pDateTime) = 2 and 
               isObject(pDateTime[1]) and isObject(pDateTime[2])
                # [stzDate, stzTime] format
                if pDateTime[1].IsAStzDate()
                    oQDateTime.setDate(pDateTime[1].QDateObject())
                ok
                if pDateTime[2].IsAStzTime()
                    oQDateTime.setTime(pDateTime[2].QTimeObject())
                ok
            
            but IsHashList(pDateTime)
                # Hash format
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
                
                oDate = new QDate()
                oDate.setDate(nYear, nMonth, nDay)
                oTime = new QTime()
                oTime.setHMS(nHour, nMinute, nSecond, 0)
                
                oQDateTime.setDate(oDate)
                oQDateTime.setTime(oTime)
            ok
        ok
        
        if not oQDateTime.isValid()
            StzRaise("Invalid date/time provided!")
        ok
    
    def ParseStringDateTime(cDateTime)
        # Try Qt built-in formats first (using numeric constants)
        aQtFormats = [ 1, 0 ] # ISODate=1, TextDate=0
        
        for nFormat in aQtFormats
            oTemp = new QDateTime()
            oTemp = oTemp.fromString(cDateTime, nFormat)
            
            if oTemp.isValid()
                oQDateTime = oTemp
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
                oQDateTime = oTemp
                return
            ok
        next
        
        StzRaise("Cannot parse date/time string: " + cDateTime)
    
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
        oQDateTime = oQDateTime.addDays(nDays)
        return This.ToString()
    
    def AddDaysQ(nDays)
        This.AddDays(nDays)
        return This
    
    def AddMonths(nMonths)
        oQDateTime = oQDateTime.addMonths(nMonths)
        return This.ToString()
    
    def AddMonthsQ(nMonths)
        This.AddMonths(nMonths)
        return This
    
    def AddYears(nYears)
        oQDateTime = oQDateTime.addYears(nYears)
        return This.ToString()
    
    def AddYearsQ(nYears)
        This.AddYears(nYears)
        return This
    
    def AddSeconds(nSeconds)
        oQDateTime = oQDateTime.addSecs(nSeconds)
        return This.ToString()
    
    def AddSecondsQ(nSeconds)
        This.AddSeconds(nSeconds)
        return This
    
    def AddMinutes(nMinutes)
        oQDateTime = oQDateTime.addSecs(nMinutes * 60)
        return This.ToString()
    
    def AddMinutesQ(nMinutes)
        This.AddMinutes(nMinutes)
        return This
    
    def AddHours(nHours)
        oQDateTime = oQDateTime.addSecs(nHours * 3600)
        return This.ToString()
    
    def AddHoursQ(nHours)
        This.AddHours(nHours)
        return This
    
    def AddMilliseconds(nMs)
        oQDateTime = oQDateTime.addMSecs(nMs)
        return This.ToStringXT("yyyy-MM-dd hh:mm:ss.zzz")
    
    def AddMillisecondsQ(nMs)
        This.AddMilliseconds(nMs)
        return This

    def SubtractDays(nDays)
        oQDateTime = oQDateTime.addDays(-nDays)
        return This.ToString()
    
    def SubtractDaysQ(nDays)
        This.SubtractDays(nDays)
        return This

    def SubtractMonths(nMonths)
        oQDateTime = oQDateTime.addMonths(-nMonths)
        return This.ToString()
    
    def SubtractMonthsQ(nMonths)
        This.SubtractMonths(nMonths)
        return This

    def SubtractYears(nYears)
        oQDateTime = oQDateTime.addYears(-nYears)
        return This.ToString()
    
    def SubtractYearsQ(nYears)
        This.SubtractYears(nYears)
        return This

    def SubtractSeconds(nSeconds)
        oQDateTime = oQDateTime.addSecs(-nSeconds)
        return This.ToString()
    
    def SubtractSecondsQ(nSeconds)
        This.SubtractSeconds(nSeconds)
        return This

    def SubtractMilliSeconds(nMilliSeconds)
        oQDateTime = oQDateTime.addMSecs(-nMilliSeconds)
        return This.ToStringXT("yyyy-mm-dd hh:mm:ss.zzz")
    
    def SubtractMilliSecondsQ(nMilliSeconds)
        This.SubtractMilliSeconds(nMilliSeconds)
        return This

    def SubtractMinutes(nMinutes)
        oQDateTime = oQDateTime.addSecs(-nMinutes * 60)
        return This.ToString()
    
    def SubtractMinutesQ(nMinutes)
        This.SubtractMinutes(nMinutes)
        return This

    def SubtractHours(nHours)
        oQDateTime = oQDateTime.addSecs(-nHours * 3600)
        return This.ToString()
    
    def SubtractHoursQ(nHours)
        This.SubtractHours(nHours)
        return This

    #--- OPERATOR OVERLOADING ---#
    
	def operator(op, v)

	    if op = "+"
	        if isNumber(v)
	            This.AddSeconds(v)
	            return This
	        
	        but isString(v)
	            # Check if it's a natural language expression
	            cLower = lower(trim(v))
	            bHasDateTime = (substr(v, "-") > 0 and substr(v, ":") > 0)
	            bHasUnits = (substr(cLower, " day") > 0 or substr(cLower, " month") > 0 or 
	                        substr(cLower, " year") > 0 or substr(cLower, " hour") > 0 or 
	                        substr(cLower, " minute") > 0 or substr(cLower, " second") > 0)
	            
	            if not bHasDateTime and bHasUnits
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
		
		        # Only treat as natural language if it contains time units with spaces
		        cLower = lower(trim(v))
		        bHasDateTime = (substr(v, "-") > 0 and substr(v, ":") > 0)
		        bHasUnits = (substr(cLower, " day") > 0 or substr(cLower, " month") > 0 or 
		                    substr(cLower, " year") > 0 or substr(cLower, " hour") > 0 or 
		                    substr(cLower, " minute") > 0 or substr(cLower, " second") > 0)
		        
		        if not bHasDateTime and bHasUnits
		            This.SubtractNatural(v)
		            return This
		
		        else
		            oOtherDateTime = new stzDateTime(v)
		            return This.SecsTo(oOtherDateTime)
		
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
	            oTemp = new stzDateTime(v)
	            return This.IsBefore(oTemp) or This.IsEqualTo(oTemp)
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
	            oTemp = new stzDateTime(v)
	            return This.IsAfter(oTemp) or This.IsEqualTo(oTemp)
	        ok
	    
	    but op = "="
	        if isObject(v) and v.IsAStzDateTime()
	            return This.IsEqualTo(v)

	        but isString(v)
	            return This.IsEqualTo(new stzDateTime(v))
	        ok
	    ok

	
	def AddNatural(cExpr)
	    cExpr = lower(trim(cExpr))

	    # Don't process if it looks like a datetime string

		Rx = new stzRegex(pat(:DateTime))
	    if Rx.Match(cExpr)
	        return
	    ok
	    
	    aParts = split(cExpr, " ")
	    
	    i = 1
	    while i <= len(aParts)
	        if isNumber(0+ aParts[i])
	            nValue = 0+ aParts[i]
	            if i < len(aParts)
	                cUnit = lower(aParts[i+1])
	                
	                if cUnit = "day" or cUnit = "days"
	                    This.AddDays(nValue)

	                but cUnit = "month" or cUnit = "months"
	                    This.AddMonths(nValue)

	                but cUnit = "year" or cUnit = "years"
	                    This.AddYears(nValue)

	                but cUnit = "hour" or cUnit = "hours"
	                    This.AddHours(nValue)

	                but cUnit = "minute" or cUnit = "minutes"
	                    This.AddMinutes(nValue)

	                but cUnit = "second" or cUnit = "seconds"
	                    This.AddSeconds(nValue)

	                but cUnit = "millisecond" or cUnit = "milliseconds"
	                    This.AddMilliseconds(nValue)
	                ok
	                
	                i += 2
	            else
	                i++
	            ok
	        else
	            i++
	        ok
	    end
	
	def SubtractNatural(cExpr)
	    cExpr = lower(trim(cExpr))
	    
	    # Don't process if it looks like a datetime string
	    if substr(cExpr, "-") > 0 or substr(cExpr, ":") > 0 or substr(cExpr, "T") > 0
	        return
	    ok
	    
	    aParts = split(cExpr, " ")
	    
	    i = 1
	    while i <= len(aParts)
	        if isNumber(0+ aParts[i])
	            nValue = 0+ aParts[i]
	            if i < len(aParts)
	                cUnit = lower(aParts[i+1])
	                
	                if cUnit = "day" or cUnit = "days"
	                    This.SubtractDays(nValue)

	                but cUnit = "month" or cUnit = "months"
	                    This.SubtractMonths(nValue)

	                but cUnit = "year" or cUnit = "years"
	                    This.SubtractYears(nValue)

	                but cUnit = "hour" or cUnit = "hours"
	                    This.SubtractHours(nValue)

	                but cUnit = "minute" or cUnit = "minutes"
	                    This.SubtractMinutes(nValue)

	                but cUnit = "second" or cUnit = "seconds"
	                    This.SubtractSeconds(nValue)

	                but cUnit = "millisecond" or cUnit = "milliseconds"
	                    This.SubtractMilliSeconds(nValue)
	                ok
	                
	                i += 2
	            else
	                i++
	            ok
	        else
	            i++
	        ok
	    end
    
    #--- DURATION CALCULATIONS ---#
    
    def DaysTo(oOtherDateTime)
        if isString(oOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(oOtherDateTime)
			return This.DaysTo(_oOtherDateTime_)
        ok

        return oQDateTime.daysTo(oOtherDateTime.QDateTimeObject())
    
	def SecsTo(oOtherDateTime)
	    if isString(oOtherDateTime)
	        _oOtherDateTime_ = new stzDateTime(oOtherDateTime)
			return This.SecsTo(_oOtherDateTime_)
	    ok
	    return oQDateTime.secsTo(oOtherDateTime.QDateTimeObject())
    
    def MSecsTo(oOtherDateTime)
        if isString(oOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(oOtherDateTime)
			return This.ToMSecsTo(_oOtherDateTime_)
        ok
        return oQDateTime.msecsTo(oOtherDateTime.QDateTimeObject())

    def MinutesTo(oOtherDateTime)
        if isString(oOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(oOtherDateTime)
			return This.MinutesTo(_oOtherDateTime_)
        ok
        return floor(This.SecsTo(oOtherDateTime) / 60)

    def HoursTo(oOtherDateTime)
        if isString(oOtherDateTime)
            _oOtherDateTime_ = new stzDateTime(oOtherDateTime)
			return This.HoursTo(_oOtherDateTime_)
        ok
        return floor(This.SecsTo(oOtherDateTime) / 3600)

	def DurationTo(oOtherDateTime)
	 
	        if isString(oOtherDateTime)
	            _oOtherDateTime_ = new stzDateTime(oOtherDateTime)
				return This.DurationTo(_oOtherDateTime_)
	        ok
	
	        nTotalMSecs = This.MSecsTo(oOtherDateTime)
	        if nTotalMSecs < 0
	            nTotalMSecs = -nTotalMSecs
	        ok
	
	        nDays = floor(nTotalMSecs / 86400000)
	        nRemainingMSecs = nTotalMSecs - (nDays * 86400000)
	
	        nHours = floor(nRemainingMSecs / 3600000)
	        nRemainingMSecs = nRemainingMSecs - (nHours * 3600000)
	
	        nMinutes = floor(nRemainingMSecs / 60000)
	        nRemainingMSecs = nRemainingMSecs - (nMinutes * 60000)
	
	        nSeconds = floor(nRemainingMSecs / 1000)
	        nMilliseconds = nRemainingMSecs - (nSeconds * 1000)
	
			return [ :Days = nDays, :Hours = nHours, :Minutes = nMinutes, :Seconds = nSeconds, :Milliseconds = nMilliseconds ]
    
		def DurationToQ(oOtherDateTime)
			return new stzDuration(This.DurationTo(oOtherDateTime))

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

        def IsEqual(oOtherDateTime)
            return This.IsEqualTo(oOtherDateTime)

    def IsBetween(poStartDateTime, poEndDateTime)
        if CheckParams()
            if isList(poEndDateTime) and StzListQ(poEndDateTime).IsAndNamedParam()
                _oEndDateTime_ = poEndDateTime[2]
				poEndDateTime = _oEndDateTime_
            ok
        ok

        if isString(poStartDateTime)
            _oStartDateTime_ = new stzDateTime(poStartDateTime)
			return This.IsBetween(_oStartDateTime_)
        ok

        if isString(poEndDateTime)
            _oEndDateTime_ = new stzDateTime(poEndDateTime)
			return This.ISBetween(_oEndDateTime_)
        ok
        
        return This.IsAfter(poStartDateTime) and This.IsBefore(poEndDateTime)

    def IsNow()
        _oNow_ = new QDateTime()
        _oNow_ = _oNow_.currentDateTime()
        nDiff = abs(oQDateTime.secsTo(_oNow_))
        return nDiff < 60  # Within 1 minute

    def IsToday()
        return This.DateQ().IsToday()

    def IsTomorrow()
        return This.DateQ().IsTomorrow()

    def IsYesterday()
        return This.DateQ().IsYesterday()

    #--- UNIX TIMESTAMP ---#
    
    def ToUnixTimeStamp()
        return oQDateTime.toMSecsSinceEpoch() / 1000
    
    def ToUnixTimeStampMs()
        return oQDateTime.toMSecsSinceEpoch()
    
    #--- TIME ZONE OPERATIONS ---#
    
    def ToUTCQ()
        oResult = oQDateTime.toUTC()
        oNewDateTime = new stzDateTime("")
        oNewDateTime.SetQDateTime(oResult)
        return oNewDateTime

		def ToUTC()
			return This.ToUTCQ().Content()
    
    def ToLocalTimeQ()
        oResult = oQDateTime.toLocalTime()
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
	        if oQDateTime.time().msec() > 0
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
		        return oQDateTime.toString("dd/MM/yyyy HH:mm")  # 15/03/2024 14:30
		    
		    # Long formats (verbose, fully spelled out)
		    but cFormat = "long" or cFormat = "long12h"
		        return This.ToLong()  # Default: 12-hour (dddd, MMMM d, yyyy h:mm:ss AM/PM)
		    
		    but cFormat = "long24h"
		        return oQDateTime.toString("dddd, MMMM d, yyyy HH:mm:ss")  # Friday, March 15, 2024 14:30:45
		    
		    # Short formats (minimal, no year sometimes)
		    but cFormat = "short" or cFormat = "short12h"
		        nHour = This.Hours()
		        nHour12 = ConvertTo12Hour(nHour)
		        cAmPm = GetAmPmText(nHour)
		        return oQDateTime.toString("dd/MM") + " " + nHour12 + ":" + 
		               Right("0" + This.Minutes(), 2) + " " + cAmPm  # 15/03 2:30 PM
		    
		    but cFormat = "short24h"
		        return oQDateTime.toString("dd/MM HH:mm")  # 15/03 14:30
		    
		    # Medium formats (balanced detail)
		    but cFormat = "medium" or cFormat = "medium12h"
		        nHour = This.Hours()
		        nHour12 = ConvertTo12Hour(nHour)
		        cAmPm = GetAmPmText(nHour)
		        return oQDateTime.toString("ddd, MMM d") + " " + nHour12 + ":" + 
		               Right("0" + This.Minutes(), 2) + " " + cAmPm  # Fri, Mar 15 2:30 PM
		    
		    but cFormat = "medium24h"
		        return oQDateTime.toString("ddd, MMM d HH:mm")  # Fri, Mar 15 14:30
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
	        
	        cResult = oQDateTime.toString(cFormatFinal)
	        cAmPm = GetAmPmText(nHour)
	        
	        return cResult + " " + cAmPm
	    else
	        # Standard 24-hour format
	        return oQDateTime.toString(cQtFormat)
	    ok
	
	# Short formats

	def ToShort()
	    return This.ToStringXT(:Short)
	
	def ToShort12h()
	    return This.ToStringXT(:Short12h)
	
	def ToShort24h()
	    return This.ToStringXT(:Short24h)
	
	# Medium formats

	def ToMedium()
	    return This.ToStringXT(:Medium)
	
	def ToMedium12h()
	    return This.ToStringXT(:Medium12h)
	
	def ToMedium24h()
	    return This.ToStringXT(:Medium24h)
	    
	#--

	def ToISO8601()
	    return This.ToStringXT(:ISO8601)
	
	def ToISOWithMs()
	    return This.ToStringXT(:ISOWithMs)
	
	#--

	def ToCompact()
	    return This.ToStringXT(:Compact12h)
	
		def ToCompact12h()
			return This.ToStringXT(:Compact12h)

	def ToCompact24h()
		return This.ToStringXT(:Compact)

	#--
	
	def ToStandard()
	    return This.ToStringXT(:Standard12h)
	
		def ToStandard12h()
			return This.ToStringXT(:Standard12h)

	def ToStandard24h()
	    return This.ToStringXT(:Standard)

	#--

	def ToEuropean()
	    return This.ToStringXT(:European12h)
	
		def ToEuropean12h()
			return This.ToStringXT(:European12h)

	def ToEuropean24h()
	    return This.ToStringXT(:European)

	#--

	def ToAmerican()
	    return This.ToStringXT(:American12h)
	
		def ToAmerican12h()
			return This.ToStringXT(:American12h)

	def ToAmerican24h()
	    return This.ToStringXT(:American)
	
	#--

	def ToISO()
	    return This.ToStringXT(:Iso12h)
	
		def ToIso12h()
			return This.ToStringXT(:Iso12h)

	def ToIso24h()
	    return This.ToStringXT(:ISO)

	# 12-hour variants with automatic AM/PM
	
	def ToVerbose()
		return This.ToStringXT(:Verbose12h)

	def ToVerbose12h()
	    return This.ToStringXT(:Verbose12h)

	def ToVerbose24h()
	    return This.ToStringXT(:Verbose)

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
	    
	    cResult = oQDateTime.toString("dd/MM/yyyy") + " " + nHour12 + ":" + 
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
	    
	    cResult = oQDateTime.toString("dddd, MMMM d, yyyy") + " " + nHour12 + ":" + 
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

	def ToString12h()
	    nHour = This.Hours()
	    nHour12 = ConvertTo12Hour(nHour)
	    cAmPm = GetAmPmText(nHour)
	    
	    return oQDateTime.toString("yyyy-MM-dd") + " " + nHour12 + ":" +
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
        oQDateTime = oNewQDateTime
        return This

    def SetQDateTimeQ(oNewQDateTime)
        This.SetQDateTime(oNewQDateTime)
        return This
    
    def QDateTimeObject()
        return oQDateTime
    
    def IsValid()
        if oQDateTime.isValid()
            return TRUE
        else
            return FALSE
        ok
    
    def IsAStzDateTime()
        return TRUE
