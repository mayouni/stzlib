
$aDaysOfWeek = [
	[ "1", :Monday ],
	[ "2", :Tuesday ],
	[ "3", :Wednesday ],
	[ "4", :Thursday ],
	[ "5", :Friday ],
	[ "6", :Saturday ],
	[ "7", :Sunday ]
]

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

#=== UTILITY FUNCTIONS ===#

func DaysOfWeek()
	return $aDaysOfWeek

func GetDayByName(nDayOfWeek)
	return GetDayByNameXT(nDayOfWeek, :English)

func GetDayName(nDayOfWeek)
	return GetDayNameXT(nDayOfWeek, :English)

func GetDayNameXT(nDayOfWeek, cLanguage)
    if cLanguage = NULL
        cLanguage = $cCurrentLanguage
    ok
    
    for aLang in $aDayNames
        if aLang[1] = cLanguage
            return aLang[2][nDayOfWeek]
        ok
    next
    
    # Fallback to English
    for aLang in $aDayNames
        if aLang[1] = :English
            return aLang[2][nDayOfWeek]
        ok
    next

	func GetDayNameInLanguage(nDayOfWeek, cLanguage)
		return GetDayNameXT(nDayOfWeek, cLanguage)

func GetMonthName(nMonth)
	return GetMonthNameInLanguage(nMonth, :English)

func GetMonthNameInLanguage(nMonth, cLanguage)
    if cLanguage = NULL
        cLanguage = $cCurrentLanguage
    ok
    
    for aLang in $aMonthNames
        if aLang[1] = cLanguage
            return aLang[2][nMonth]
        ok
    next
    
    # Fallback to English
    for aLang in $aMonthNames
        if aLang[1] = :English
            return aLang[2][nMonth]
        ok
    next

	func GetMonthNameXT(nMonth, cLanguage)
		return GetMonthNameInLanguage(nMonth, cLanguage)

func SysDate()
	return date()

	func DateSys()
		return date()

func ring_addDays(cDate, n)
	return addDays(cDate, n)

func StzDateQ(pDate)
    return new stzDate(pDate)

func Now()
	return Date() + " " + Time()

func TodayQ()
    return StzDateQ(DateSys())

	func Today()
		return TodayQ().ToString()

#=== ENHANCED stzDate CLASS ===#

class stzDate from stzObject
    oQDate
    
    def init(pDate)
        oQDate = new QDate()
        
        if pDate = NULL or pDate = ""
            oQDate = oQDate.currentDate()
        else
            # Always expect string input
            if not isString(pDate)
                pDate = ""+ pDate
            ok
            This.ParseStringDate(pDate)
        ok
        
        if not oQDate.isValid()
            StzRaise("Invalid date provided!")
        ok
    
    def ParseStringDate(cDate)
        # Try common formats
        aFormats = [ "dd/MM/yyyy", "MM/dd/yyyy", "yyyy-MM-dd", 
                    "dd-MM-yyyy", "yyyy/MM/dd", "ddMMyyyy" ]
        
        for cFormat in aFormats
            oTemp = oQDate.fromString(cDate, cFormat)
            if oTemp.isValid()
                oQDate = oTemp
                return
            ok
        next
        
        StzRaise("Cannot parse date string: " + cDate)
    
    #--- ARITHMETIC OPERATIONS (Mutable Softanza Style) ---#
    
    def AddDays(nDays)
        oQDate = oQDate.addDays(nDays)
        return This.ToString()
 
		def AddDaysQ(nDays)
			This.AddDays(nDays)
			return This

    def AddMonths(nMonths)
        oQDate = oQDate.addMonths(nMonths)
        return This.ToString()

		def AddMonthsQ(nMonths)
			This.AddMonths(nMonths)
			return This

    def AddYears(nYears)
        oQDate = oQDate.addYears(nYears)
        return This.ToString()

		def AddYearsQ(nYears)
			This.AddYears(nYears)
			return This

    def SubtractDays(nDays)
        oQDate = oQDate.addDays(-nDays)
        return This.ToString()

		def SubtractDaysQ(nDays)
			This.SubtractDays(nDays)
			return This

    def SubtractMonths(nMonths)
        oQDate = oQDate.addMonths(-nMonths)
        return This.ToString()
    
		def SubtractMonthsQ(nMonths)
			This.SubtractMonths(nMonths)
			return This

    def SubtractYears(nYears)
        oQDate = oQDate.addYears(-nYears)
        return This.ToString()
    
		def SubtractYearsQ(nYears)
			This.SubtractYears(nYears)
			return This

    #--- OPERATOR OVERLOADING ---#
    
    def operator(op, v)
        if op = "+"
            if isNumber(v)
                return This.AddDays(v)
            but isString(v)
                return This.ParseOperation(v, "+")
            ok
        but op = "-"
            if isNumber(v)
                return This.SubtractDays(v)
            but isString(v)
                return This.ParseOperation(v, "-")
            ok
        ok
    
    def ParseOperation(cOperation, cOperator)
        acWords = @split(cOperation, " ")
        
        if len(acWords) != 2
            StzRaise("Invalid operation format. Use 'n days/months/years'")
        ok
        
        nValue = 0+ acWords[1]
        cUnit = lower(acWords[2])
        
        if cOperator = "-"
            nValue = -nValue
        ok
        
        if cUnit = "day" or cUnit = "days"
            return This.AddDays(nValue)
        but cUnit = "month" or cUnit = "months"
            return This.AddMonths(nValue)
        but cUnit = "year" or cUnit = "years"
            return This.AddYears(nValue)
        else
            StzRaise("Invalid unit! Use 'days', 'months', or 'years'.")
        ok
    
    #--- COMPARISON METHODS ---#
    
    def DaysTo(oOtherDate)
        if isString(oOtherDate)
            oOtherDate = new stzDate(oOtherDate)
        ok
        
        if not isObject(oOtherDate) or not oOtherDate.IsAStzDate()
            StzRaise("Parameter must be a stzDate object or date string")
        ok
        return oQDate.daysTo(oOtherDate.QDateObject())
    
    def IsBefore(oOtherDate)
        return This.DaysTo(oOtherDate) > 0
    
    def IsAfter(oOtherDate)
        return This.DaysTo(oOtherDate) < 0
    
    def IsEqual(oOtherDate)
        return This.DaysTo(oOtherDate) = 0
    
    #--- GETTERS (Return strings by default) ---#
    
    def Year()
        return ""+ oQDate.year()
        
        def YearInNumber()
            return oQDate.year()
            
        def YearN()
            return oQDate.year()
            
        def YearNumberInString()
            return ""+ oQDate.year()
    
    def Month()
        return GetMonthName(oQDate.month())
        
        def MonthInNumber()
            return oQDate.month()
            
        def MonthN()
            return oQDate.month()
            
        def MonthNumberInString()
            return ""+ oQDate.month()
            
   def MonthInLanguage(cLanguage)
        return GetMonthNameXT(oQDate.month(), cLanguage)
    
		def MonthIn(cLanguage)
			return This.MonthInLanguage(cLanguage)

    def Day()
        return GetDayName(oQDate.dayOfWeek())
        
        def DayInNumber()
            return oQDate.day()
            
        def DayN()
            return oQDate.day()
            
        def DayNumberInString()
            return ""+ oQDate.day()
            
    def DayInLanguage(cLanguage)
        return GetDayNameXT(oQDate.dayOfWeek(), cLanguage)
 
		def DayIn(cLanguage)
			return DayInLanguage(cLanguage)

    def DayOfWeek()
        return ""+ oQDate.dayOfWeek()
        
        def DayOfWeekInNumber()
            return oQDate.dayOfWeek()
            
        def DayOfWeekN()
            return oQDate.dayOfWeek()
    
    def DayOfYear()
        return ""+ oQDate.dayOfYear()
        
        def DayOfYearInNumber()
            return oQDate.dayOfYear()
            
        def DayOfYearN()
            return oQDate.dayOfYear()
    
	def WeekNumber()
		# Calculated manually using ISO standard
		# because I strugled with the RingQt version signature
		#TODO // Check it!

	    nYear = oQDate.year()
	    nMonth = oQDate.month() 
	    nDay = oQDate.day()
	    
	    # ISO week calculation
		oQDateTemp = new QDate()
		oQDateTemp.setDate(nYear, 1, 1)
	    nJan1DayOfWeek = oQDateTemp.dayOfWeek()

	    nDayOfYear = oQDate.dayOfYear()
	    
	    nWeek = floor((nDayOfYear + nJan1DayOfWeek - 2) / 7) + 1
	    
	    # Handle edge cases for ISO weeks
	    if nWeek = 0
	        nWeek = 52
			oQDateTemp = new QDate()
			oQDateTemp.setDate(nYear-1, 12, 31)
	        if oQDateTemp.dayOfWeek() = 4
	            nWeek = 53
	        ok
	    ok
	    
	    return nWeek
	   
    
    def DaysInMonth()
        return ""+ oQDate.daysInMonth()
        
        def DaysInMonthInNumber()
            return oQDate.daysInMonth()
            
        def DaysInMonthN()
            return oQDate.daysInMonth()
    
    def DaysInYear()
        return ""+ oQDate.daysInYear()
        
        def DaysInYearInNumber()
            return oQDate.daysInYear()
            
        def DaysInYearN()
            return oQDate.daysInYear()
    
    def IsLeapYear()
        if oQDate.isLeapYear(This.YearN())
            return "true"
        else
            return "false"
        ok
        
        def IsLeapYearInLogical()
            return oQDate.isLeapYear(This.YearN())
            
        def IsLeapYearL()
            return oQDate.isLeapYear(This.YearN())
    
    #--- FORMATTING ---#
    
	def ToString()
		return This.ToStringXT("")

	def ToStringXT(cFormat)
	    if cFormat = NULL or cFormat = ""
	        cFormat = $cDefaultDateFormat
	    ok
	    
	    # Handle named formats (case-insensitive)
	    cLowerFormat = lower(cFormat)
	    for aFormat in $aDateFormats
	        if lower(aFormat[1]) = cLowerFormat
	            cFormat = aFormat[2]
	            exit
	        ok
	    next
	    
	    return oQDate.toString(cFormat)
    
    def ToISO8601()
        return This.ToStringXT("yyyy-MM-dd")
    
    def ToEuropean()
        return This.ToStringXT("dd/MM/yyyy")
    
    def ToAmerican()
        return This.ToStringXT("MM/dd/yyyy")
    
    #--- UTILITY METHODS ---#
    
    def SetQDate(oNewQDate)
        oQDate = oNewQDate

		def SetQDateQ(oNewQDate)
			This.SetQDate(oNewQDate)
        	return This
    
    def QDateObject()
        return oQDate
    
    def IsValid()
        if oQDate.isValid()
            return "true"
        else
            return "false"
        ok
        
        def IsValidInLogical()
            return oQDate.isValid()
            
        def IsValidL()
            return oQDate.isValid()
    
    def IsAStzDate()
        return TRUE
