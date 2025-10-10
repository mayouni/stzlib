
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

func TimeStamp()
	return Date() + " " + Time()

# Quick date creation functions
func Yesterday()
    return StzDateQ("").SubtractDaysQ(1).Content()

func Tomorrow()
    return StzDateQ("").AddDaysQ(1).Content()

func StartOfWeek()
    oDate = StzDateQ("")
    nDaysToSubtract = oDate.DayOfWeekN() - 1
    return oDate.SubtractDaysQ(nDaysToSubtract).Content()

func EndOfWeek()
    oDate = StartOfWeek()
    return oDate.AddDaysQ(6).Content()

func StartOfMonth()
    oDate = StzDateQ("")
    return StzDateQ("01/" + oDate.MonthNumberInString() + "/" + oDate.Year()).Content()

func EndOfMonth()
    oDate = StzDateQ("")
    nDays = oDate.DaysInMonthN()
    return StzDateQ('' + nDays + "/" + oDate.MonthNumberInString() + "/" + oDate.Year()).Content()


#=== UTILITY FUNCTIONS ===#

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

func IsDate(str)
	Rx = Rx(pat(:Date))
	return Rx.Match(str)

	func IsValidDate(str)
		return IsDate(str)

func DayOrdinalSuffix(nDay)
    if nDay % 10 = 1 and nDay != 11
        return "st"
    but nDay % 10 = 2 and nDay != 12
        return "nd"
    but nDay % 10 = 3 and nDay != 13
        return "rd"
    else
        return "th"
    ok

class stzDate from stzObject
   	 oQDate
    
    	def init(pcDate)
		This.SetDate(pcDate)

	def SetDate(pcDate)
	    if isList(pcDate) and len(pcDate) = 3
	        if IsListOfNumbers(pcDate)
	            pcDate = '' + pcDate[1] + "-" + pcDate[2] + "-" + pcDate[3]
	        but IsHashList(pcDate) and HasKeys(pcDate, [ :Year, :Month, :Day ])
	            pcDate = '' + pcDate[:Year] + "-" + pcDate[:Month] + "-" + pcDate[:Day]
	        ok
	    ok
	
	    if NOT isString(pcDate)
	        StzRaise("Can't create the stzDate object! You must provide a string.")
	    ok
	
	    oQDate = new QDate()
	    cDate = lower(trim(pcDate))
	    nLenDate = len(cDate)
	
	
	    if cDate = ''
	        oQDate = oQDate.currentDate()
	        return

	    but cDate = "today"
	        oQDate = oQDate.currentDate()
	        return
	    
	    but cDate = "yesterday"
	        oQDate = oQDate.currentDate().addDays(-1)
	        return

	    but cDate = "tomorrow"
	        oQDate = oQDate.currentDate().addDays(1)
	        return
	    ok
	
	    if left(cDate, 3) = "in "
	        aValueUnit = ExtractValueAndUnit(substr(cDate, 4))
	        if aValueUnit != NULL
	            nValue = aValueUnit[1]
	            cUnit = aValueUnit[2]
	            
	            switch cUnit
	                on "day"
	                    oQDate = oQDate.currentDate().addDays(nValue)
	                on "days"
	                    oQDate = oQDate.currentDate().addDays(nValue)
	                on "week"
	                    oQDate = oQDate.currentDate().addDays(nValue * 7)
	                on "weeks"
	                    oQDate = oQDate.currentDate().addDays(nValue * 7)
	                on "month"
	                    oQDate = oQDate.currentDate().addMonths(nValue)
	                on "months"
	                    oQDate = oQDate.currentDate().addMonths(nValue)
	                on "year"
	                    oQDate = oQDate.currentDate().addYears(nValue)
	                on "years"
	                    oQDate = oQDate.currentDate().addYears(nValue)
	                on "decade"
	                    oQDate = oQDate.currentDate().addDays(nValue * 3650)
	                on "decades"
	                    oQDate = oQDate.currentDate().addDays(nValue * 3650)
	                on "century"
	                    oQDate = oQDate.currentDate().addDays(nValue * 36500)
	                on "centuries"
	                    oQDate = oQDate.currentDate().addDays(nValue * 36500)
	            off
	            return
	        ok
	    ok
	
	    This.ParseStringDate(pcDate)
	
	    if not oQDate.isValid()
	        StzRaise("Invalid date provided!")
	    ok
	
    def ParseStringDate(cDate)
        # Enhanced parser with more formats
        aFormats = [ 
            "dd/MM/yyyy", "MM/dd/yyyy", "yyyy-MM-dd", 
            "dd-MM-yyyy", "yyyy/MM/dd", "ddMMyyyy",
            "d/M/yyyy", "M/d/yyyy", "yyyy-M-d",
            "d-M-yyyy", "dd.MM.yyyy", "MM.dd.yyyy"
        ]
        
        for cFormat in aFormats
            oTemp = oQDate.fromString(cDate, cFormat)
            if oTemp.isValid()
                oQDate = oTemp
                return
            ok
        next
        
        StzRaise("Cannot parse date string: " + cDate)
    
    #--- ENHANCED ARITHMETIC OPERATIONS ---#
    
    def AddDays(nDays)
        oQDate = oQDate.addDays(nDays)
        return This.ToString()
 
	    def AddDaysQ(nDays)
	        This.AddDays(nDays)
	        return This

    def AddWeeks(nWeeks)
        oQDate = oQDate.addDays(nWeeks * 7)
        return This.ToString()

	    def AddWeeksQ(nWeeks)
	        This.AddWeeks(nWeeks)
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

    def SubtractWeeks(nWeeks)
        oQDate = oQDate.addDays(-nWeeks * 7)
        return This.ToString()

	    def SubtractWeeksQ(nWeeks)
	        This.SubtractWeeks(nWeeks)
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

    #--- SMART NAVIGATION METHODS ---#
    
    def NextWeekday()
        nCurrentDay = oQDate.dayOfWeek()
        if nCurrentDay < 5  # Monday-Thursday
            return This.AddDays(1)
        else  # Friday-Sunday
            return This.AddDays(8 - nCurrentDay)
        ok

    def PreviousWeekday()
        nCurrentDay = oQDate.dayOfWeek()
        if nCurrentDay > 1  # Tuesday-Sunday
            return This.SubtractDays(1)
        else  # Monday
            return This.SubtractDays(3)
        ok

    def NextMonday()
        nDaysToAdd = 8 - oQDate.dayOfWeek()
        if nDaysToAdd = 8
            nDaysToAdd = 7
        ok
        return This.AddDays(nDaysToAdd)

    def LastDayOfMonth()
        oQDate = oQDate.setDate(oQDate.year(), oQDate.month(), oQDate.daysInMonth())
        return This.ToString()

    def FirstDayOfMonth()
        oQDate = oQDate.setDate(oQDate.year(), oQDate.month(), 1)
        return This.ToString()

    def StartOfYear()
        oQDate = oQDate.setDate(oQDate.year(), 1, 1)
        return This.ToString()

    def EndOfYear()
        oQDate = oQDate.setDate(oQDate.year(), 12, 31)
        return This.ToString()

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
				(isString(v) and IsDate(v))

				return This.IsBefore(v)

			else
				StzRaise("Unsupported value! Only a stzDate onject or a date in string can be provided.")
			ok

		but op = "<="

			if (isObject(v) and v.IsAStzDate()) or
				(isString(v) and IsDate(v))

				return This.IsBefore(v) or This.IsEqualTo(v)

			else
				StzRaise("Unsupported value! Only a stzDate onject or a date in string can be provided.")
			ok

		but op = ">"
			if (isObject(v) and v.IsAStzDate()) or
				(isString(v) and IsDate(v))

				return This.IsAfter(v)

			else
				StzRaise("Unsupported value! Only a stzDate onject or a date in string can be provided.")
			ok

		but op = ">="
			if (isObject(v) and v.IsAStzDate()) or
				(isString(v) and IsDate(v))

				return This.IsAfter(v) or This.IsEqualTo(v)

			else
				StzRaise("Unsupported value! Only a stzDate onject or a date in string can be provided.")
			ok

		but op = "="
			if (isObject(v) and v.IsAStzDate()) or
				(isString(v) and IsDate(v))

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

        nResult = oQDate.daysTo(oOtherDate.QDateObject())
	return nResult

    def WeeksTo(oOtherDate)
        return floor(This.DaysTo(oOtherDate) / 7)

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
        nMonths = oOtherDate.Month() - This.Month()
        
        return (nYears * 12) + nMonths

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
        nDay = oQDate.dayOfWeek()
        return (nDay = 6 or nDay = 7)  # Saturday or Sunday

    def IsWeekday()
        return not This.IsWeekend()

    def IsToday()
        oToday = new QDate()
        oToday = oToday.currentDate()

        nDays = oQDate.daysTo(oToday)

		if nDays = 0
			return 1
		else
			return 0
		ok

    def IsYesterday()
        _oYesterday_ = new QDate()
        _oYesterday_ = _oYesterday_.currentDate().addDays(-1)
        return oQDate.daysTo(_oYesterday_) = 0

    def IsTomorrow()
        _oTomorrow_ = new QDate()
        _oTomorrow_ = _oTomorrow_.currentDate().addDays(1)
        return oQDate.daysTo(_oTomorrow_) = 0

    def Age()
        _oToday_ = new stzDate("")
        nYears = This.YearsTo(_oToday_)
        if nYears < 0
            nYears = -nYears
        ok
        return nYears

    #--- ENHANCED GETTERS ---#
    
    def Year()
        return oQDate.year()
  
    	def YearN()
        	return oQDate.year()

    def Month()
        return GetMonthName(oQDate.month())

		def MonthName()
			return GetMonthName(oQDate.month())

    def MonthN()
        return oQDate.month()

	    def MonthNumber()
	        return oQDate.month()
        
    def MonthInLanguage(cLanguage)
        return GetMonthNameXT(oQDate.month(), cLanguage)
    
    def MonthIn(cLanguage)
        return This.MonthInLanguage(cLanguage)

    def MonthShort()
        cMonth = This.Month()
        return left(cMonth, 3)

    def Day()
        return GetDayName(oQDate.dayOfWeek())
        
    def DayN()
        return oQDate.day()

   	 	def DayNumber()
        	return oQDate.day()
        
    def DayInLanguage(cLanguage)
        return GetDayNameXT(oQDate.dayOfWeek(), cLanguage)
 
    def DayIn(cLanguage)
        return DayInLanguage(cLanguage)

    def DayShort()
        cDay = This.Day()
        return left(cDay, 3)

    def DayOfWeek()
        return oQDate.dayOfWeek()
        
    	def DayOfWeekN()
        	return oQDate.dayOfWeek()
    
    def DayOfYear()
        return oQDate.dayOfYear()
        
    	def DayOfYearN()
       		 return oQDate.dayOfYear()
    
    def WeekNumber()
        nYear = oQDate.year()
        nMonth = oQDate.month() 
        nDay = oQDate.day()
        
        oQDateTemp = new QDate()
        oQDateTemp.setDate(nYear, 1, 1)
        nJan1DayOfWeek = oQDateTemp.dayOfWeek()

        nDayOfYear = oQDate.dayOfYear()
        
        nWeek = floor((nDayOfYear + nJan1DayOfWeek - 2) / 7) + 1
        
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
        return oQDate.daysInMonth()
        
    	def DaysInMonthN()
        	return oQDate.daysInMonth()
    
    def DaysInYear()
        return oQDate.daysInYear()
        
    	def DaysInYearN()
        	return oQDate.daysInYear()
    
    def IsLeapYear()
        return oQDate.isLeapYear(This.YearN())

		def ISLeap()
			return oQDate.isLeapYear(This.YearN())

    #--- HUMAN-READABLE FORMATTING ---#
    
def ToHuman()
    oToday = new stzDate("")
    nDays = This.DaysTo(oToday)
    nDays = -nDays  # Invert to get positive for future dates
    
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
        # Use the ordinal suffix properly
        nDay = This.DayN()
        cDaySuffix = DayOrdinalSuffix(nDay)
        cHuman = This.Day() + ", " + This.Month() + " " + nDay + cDaySuffix + ", " + This.Year()
        return cHuman
    ok


def ToRelative()
    oToday = new stzDate("")
    nDays = This.DaysTo(oToday)
    nDays = -nDays  # Invert to get positive for future dates
    
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
        if cFormat = NULL or cFormat = ""
            cFormat = $cDefaultDateFormat
        ok
        
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

    def ToShort()
        return This.DayShort() + " " + This.DayN() + " " + This.MonthShort()

    def ToLong()
        return This.Day() + ", " + This.Month() + " " + This.DayN() + ", " + This.Year()

#--- JULIAN DAY METHODS ---#
    
    def ToJulianDay()
        return oQDate.toJulianDay()
    
    def FromJulianDay(nJulianDay)
        oQDate = oQDate.fromJulianDay(nJulianDay)
        return This.ToString()
    
    def FromJulianDayQ(nJulianDay)
        This.FromJulianDay(nJulianDay)
        return This

    #--- BATCH OPERATIONS ---#
    
    def IsBetween(oStartDate, oEndDate)
	if CheckParams()
		if isList(oEndDate) and StzListQ(oEndDate).IsAndNamedParam()
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
        oNewDate = new stzDate("")
        oNewDate.SetQDate(new QDate())
        oNewDate.QDateObject().setDate(This.YearN(), This.MonthN(), This.DayN())
        return oNewDate

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
            return 1
        else
            return 0
        ok
    
    def IsAStzDate()
        return TRUE

   func ExtractValueAndUnit(cExpression)
	    cExpression = lower(trim(cExpression))
	    acWords = @split(cExpression, " ")
	    if len(acWords) < 2
	    
	        return NULL
	    ok
	    
	    nValue = 0 + acWords[1]
	    cUnit = acWords[2]
	    
	    return [ nValue, cUnit ]
