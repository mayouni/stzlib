# Global datetime format configurations
$cDefaultDateTimeFormat = "yyyy-MM-dd hh:mm:ss"

$aDateTimeFormats = [
    [ :Standard, "yyyy-MM-dd hh:mm:ss" ],
    [ :Short, "dd/MM/yyyy hh:mm" ],
    [ :ISO8601, "yyyy-MM-ddThh:mm:ss" ],
    [ :ISOWithMs, "yyyy-MM-ddThh:mm:ss.zzz" ],
    [ :RFC2822, "dd MMM yyyy hh:mm:ss" ],
    [ :TextDate, "ddd MMM d hh:mm:ss yyyy" ],
    [ :WithMs, "yyyy-MM-dd hh:mm:ss.zzz" ],
    [ :Simple, "dd/MM/yyyy h:mm AP" ],
    [ :Long, "dddd, MMMM d, yyyy h:mm:ss AP" ],
    [ :European, "dd/MM/yyyy hh:mm:ss" ],
    [ :American, "MM/dd/yyyy hh:mm:ss" ]
]

# Quick datetime creation functions
func StzDateTimeQ(pDateTime)
    return new stzDateTime(pDateTime)

func NowDateTime()
    return StzDateTimeQ("").ToString()

    func NowXT()
        return NowDateTime()

func IsDateTime(str)
    if not isString(str)
        return FALSE
    ok

    _oQDateTime_ = new QDateTime()
    
    # Try Qt built-in formats first
    aQtFormats = [ 1, 0 ] # ISODate, TextDate
    for nFormat in aQtFormats
        oTemp = _oQDateTime_.fromString(str, nFormat)
        if oTemp.isValid()
            return TRUE
        ok
    next
    
    # Try common custom formats
    aCustomFormats = [ 
        "yyyy-MM-dd hh:mm:ss",
        "dd/MM/yyyy hh:mm:ss",
        "MM/dd/yyyy hh:mm:ss",
        "dd-MM-yyyy hh:mm:ss",
        "yyyy-MM-dd hh:mm",
        "dd/MM/yyyy hh:mm",
        "yyyy-MM-ddThh:mm:ss",
        "yyyy-MM-ddThh:mm:ss.zzz"
    ]
    
    for cFormat in aCustomFormats
        oTemp = _oQDateTime_.fromString(str, cFormat)
        if oTemp.isValid()
            return TRUE
        ok
    next
    return FALSE

    func IsValidDateTime(str)
        return IsDateTime(str)

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
            "yyyy-MM-dd hh:mm:ss",
            "dd/MM/yyyy hh:mm:ss",
            "MM/dd/yyyy hh:mm:ss",
            "dd-MM-yyyy hh:mm:ss",
            "yyyy-MM-dd hh:mm",
            "dd/MM/yyyy hh:mm",
            "yyyy-MM-ddThh:mm:ss",
            "yyyy-MM-ddThh:mm:ss.zzz",
            "dd MMM yyyy hh:mm:ss",
            "ddd MMM d hh:mm:ss yyyy"
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
        return This.ToString()
    
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
            oOtherDateTime = new stzDateTime(oOtherDateTime)
        ok

        return oQDateTime.daysTo(oOtherDateTime.QDateTimeObject())
    
	def SecsTo(oOtherDateTime)
	    if isString(oOtherDateTime)
	        oOtherDateTime = new stzDateTime(oOtherDateTime)
	    ok
	    return oQDateTime.secsTo(oOtherDateTime.QDateTimeObject())
    
    def MSecsTo(oOtherDateTime)
        if isString(oOtherDateTime)
            oOtherDateTime = new stzDateTime(oOtherDateTime)
        ok
        return oQDateTime.msecsTo(oOtherDateTime.QDateTimeObject())

    def MinutesTo(oOtherDateTime)
        if isString(oOtherDateTime)
            oOtherDateTime = new stzDateTime(oOtherDateTime)
        ok
        return floor(This.SecsTo(oOtherDateTime) / 60)

    def HoursTo(oOtherDateTime)
        if isString(oOtherDateTime)
            oOtherDateTime = new stzDateTime(oOtherDateTime)
        ok
        return floor(This.SecsTo(oOtherDateTime) / 3600)

    def DurationTo(oOtherDateTime)
 
        if isString(oOtherDateTime)
            oOtherDateTime = new stzDateTime(oOtherDateTime)
        ok

        nTotalSecs = This.SecsTo(oOtherDateTime)
        if nTotalSecs < 0
            nTotalSecs = -nTotalSecs
        ok

        nDays = floor(nTotalSecs / 86400)
        nRemainingSecs = nTotalSecs % 86400
        nHours = floor(nRemainingSecs / 3600)
        nRemainingSecs = nRemainingSecs % 3600
        nMinutes = floor(nRemainingSecs / 60)
        nSeconds = nRemainingSecs % 60

		return [ :Days = nDays, :Hours = nHours, :Minutes = nMinutes, :Seconds = nSeconds ]

    
    #--- COMPARISON METHODS ---#
    
    def IsBefore(oOtherDateTime)
        if isString(oOtherDateTime)
            oOtherDateTime = new stzDateTime(oOtherDateTime)
        ok
        return This.SecsTo(oOtherDateTime) > 0
    
    def IsAfter(oOtherDateTime)
        if isString(oOtherDateTime)
            oOtherDateTime = new stzDateTime(oOtherDateTime)
        ok
        return This.SecsTo(oOtherDateTime) < 0
    
    def IsEqualTo(oOtherDateTime)
        if isString(oOtherDateTime)
            oOtherDateTime = new stzDateTime(oOtherDateTime)
        ok
        return This.SecsTo(oOtherDateTime) = 0

        def IsEqual(oOtherDateTime)
            return This.IsEqualTo(oOtherDateTime)

    def IsBetween(oStartDateTime, oEndDateTime)
        if CheckParams()
            if isList(oEndDateTime) and StzListQ(oEndDateTime).IsAndNamedParam()
                oEndDateTime = oEndDateTime[2]
            ok
        ok

        if isString(oStartDateTime)
            oStartDateTime = new stzDateTime(oStartDateTime)
        ok
        if isString(oEndDateTime)
            oEndDateTime = new stzDateTime(oEndDateTime)
        ok
        
        return This.IsAfter(oStartDateTime) and This.IsBefore(oEndDateTime)

    def IsNow()
        oNow = new QDateTime()
        oNow = oNow.currentDateTime()
        nDiff = abs(oQDateTime.secsTo(oNow))
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

    
    #--- FORMATTING ---#

    def ToString()
        return This.ToStringXT("")

		def Content()
			return This.ToStringXT("")

		def DateTime()
			return This.ToStringXT("")

    def ToStringXT(cFormat)
        if cFormat = ""
            cFormat = $cDefaultDateTimeFormat
        ok

        # Handle named formats
        if isString(cFormat)
            cLowerFormat = lower(cFormat)
            for aFormat in $aDateTimeFormats
                if lower(aFormat[1]) = cLowerFormat
                    cFormat = aFormat[2]
                    exit
                ok
            next
        ok

        # Handle Qt format constants
        if isNumber(cFormat)
            return oQDateTime.toString(cFormat)
        else
            return oQDateTime.toString(cFormat)
        ok
    
    def ToISO8601()
        return oQDateTime.toString("yyyy-MM-ddThh:mm:ss")

        def ToISO()
            return This.ToISO8601()
    
    def ToISOWithMs()
        return oQDateTime.toString("yyyy-MM-ddThh:mm:ss.zzz")

    def ToRFC2822()
        return This.ToStringXT("dd MMM yyyy hh:mm:ss")

    def ToTextDate()
        return This.ToStringXT("ddd MMM d hh:mm:ss yyyy")

    def ToSimple()
        return This.DateQ().ToString() + " " + This.TimeQ().ToSimple()

    def ToLong()
        return This.ToStringXT("dddd, MMMM d, yyyy h:mm:ss AP")

    def ToEuropean()
        return This.ToStringXT("dd/MM/yyyy hh:mm:ss")

    def ToAmerican()
        return This.ToStringXT("MM/dd/yyyy hh:mm:ss")
    
    #--- HUMAN-READABLE ---#

    def ToHuman()
		cDateHuman = This.DateQ().ToHuman()
        cTimeHuman = This.TimeQ().ToHuman()
        
        return cDateHuman + " at " + cTimeHuman

    def ToRelative()
        oNow = new stzDateTime("")
        nSecs = This.SecsTo(oNow)
        
        if abs(nSecs) < 60
            return "just now"
        
        but nSecs < 0  # In the past
            nAbsSecs = -nSecs
            
            if nAbsSecs < 3600
                nMins = floor(nAbsSecs / 60)
                return '' + nMins + " minute" + Iff(nMins=1, "", "s") + " ago"

            but nAbsSecs < 86400
                nHours = floor(nAbsSecs / 3600)
                return '' + nHours + " hour" + Iff(nHours=1, "", "s") + " ago"

            but nAbsSecs < 604800  # Less than a week
                nDays = floor(nAbsSecs / 86400)
                return '' + nDays + " day" + Iff(nDays=1, "", "s") + " ago"

            but nAbsSecs < 2592000  # Less than 30 days
                nWeeks = floor(nAbsSecs / 604800)
                return '' + nWeeks + " week" + Iff(nWeeks=1, "", "s") + " ago"

            but nAbsSecs < 31536000  # Less than a year
                nMonths = floor(nAbsSecs / 2592000)
                return '' + nMonths + " month" + Iff(nMonths=1, "", "s") + " ago"

            else
                nYears = floor(nAbsSecs / 31536000)
                return '' + nYears + " year" + Iff(nYears=1, "", "s") + " ago"
            ok
        
        else  # In the future
            if nSecs < 3600
                nMins = floor(nSecs / 60)
                return "in " + nMins + " minute" + Iff(nMins=1, "", "s")

            but nSecs < 86400
                nHours = floor(nSecs / 3600)
                return "in " + nHours + " hour" + Iff(nHours=1, "", "s")

            but nSecs < 604800
                nDays = floor(nSecs / 86400)
                return "in " + nDays + " day" + Iff(nDays=1, "", "s")

            but nSecs < 2592000
                nWeeks = floor(nSecs / 604800)
                return "in " + nWeeks + " week" + Iff(nWeeks=1, "", "s")

            but nSecs < 31536000
                nMonths = floor(nSecs / 2592000)
                return "in " + nMonths + " month" + Iff(nMonths=1, "", "s")

            else
                nYears = floor(nSecs / 31536000)
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
