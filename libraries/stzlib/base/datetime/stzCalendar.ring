/*
	stzCalendar - Calendar Management and Capacity Planning in Softanza
	Manages calendar periods, working days, holidays, and capacity calculations
	String-first design: methods accept/return strings, ...Q() returns objects
	Ring-compliant: single init(p) parameter with flexible argument handling
*/

func StzCalendarQ(p)
	return new stzCalendar(p)

func CalendarQ(p)
	return new stzCalendar(p)

func Calendar(p)
	return new stzCalendar(p)

class stzCalendar from stzObject
	@cStartDate = ""        # String: start date
	@cEndDate = ""          # String: end date
	@nYear = 0
	@nMonth = 0
	@cQuarter = ""
	
	@aWorkingDays = []  # [1=Mon, 2=Tue, ..., 7=Sun]
	@aHolidays = []     # [["2024-10-05", "Independence Day"], ...]
	@aBreaks = []       # [["12:00:00", "13:00:00", "Lunch"], ...]
	@cBusinessStart = "09:00:00"
	@cBusinessEnd = "17:00:00"
	@oLocale = ""
	@aEvents = []       # Timeline events marked for visualization
	@aConstraints = []  # Custom constraint definitions

	# Display dimensions
	@nVizMinWidth = 40
	@nVizWidth = 50
	@nVizHeight = 10

	# Display Characters
	@cVizBoundaryChar = "│"
	@cVizSpanStartChar = "["
	@cVizSpanEndChar = "]"

	@cVizBlockChar = "▓"
	@cVizWeekendChar = "░"
	@cVizHolidayChar = "[D]"

	@cVizTopLeftCorner = "╭"
	@cVizTopRightCorner = "╮"
	@cVizBottomLeftCorner = "╰"
	@cVizBottomRightCorner = "╯"
	@cVizTopTSeparator = "├"
	@cVizBottomTSeparator = "┤"
	@cVizHorizontalLine = "─"


	# Timeline
	@oTimeLine = NULL

	@cVizTimeLineEventChar = "●"
	@cVizTimeLineSpanChar = "▬"

	# Cache system
	@nCachedAvailableHours = -1
	@nCachedAvailableDays = -1
	@cCachedStart = ""
	@cCachedEnd = ""


	def init(p)
		# Single parameter initialization with flexible handling
		if isNumber(p) and p > 1900
			# Year only
			_initializeYear(p)
		but isList(p)
			# Named parameters or date range
			_initializeFromList(p)
		but isString(p)
			# Could be a date, year-month, or period
			_initializeFromString(p)
		else
			StzRaise("Invalid parameter for stzCalendar initialization")
		ok

	def _initializeYear(nYear)
		@nYear = nYear
		@oLocale = _setupLocale("")
		@cStartDate = "" + nYear + "-01-01"
		@cEndDate = "" + nYear + "-12-31"

	def _initializeFromString(cParam)
		@oLocale = _setupLocale("")
		cParam = trim(cParam)
		
		# Check if it's a year-quarter (e.g., "2024-Q1")
		if stzStringQ(cParam).Contains("-Q")
			_parseQuarterString(cParam)
			return
		ok
		
		# Check if it's a year-month (e.g., "2024-10")
		if stzStringQ(cParam).Contains("-") and len(stzStringQ(cParam).Split("-")) = 2
			aParts = stzStringQ(cParam).Split("-")
			nYear = val(aParts[1])
			nMonth = val(aParts[2])
			if nMonth >= 1 and nMonth <= 12
				_initializeMonth(nYear, nMonth)
				return
			ok
		ok
		
		# Otherwise treat as a single date
		@cStartDate = cParam
		@cEndDate = cParam

	def _parseQuarterString(cQuarter)
		cQuarter = upper(trim(cQuarter))
		aParts = stzStringQ(cQuarter).Split("-")
		@nYear = val(aParts[1])
		@cQuarter = aParts[2]
		
		switch @cQuarter
		case "Q1"
			@cStartDate = ''+ @nYear + "-01-01"
			@cEndDate = ''+ @nYear + "-03-31"
		case "Q2"
			@cStartDate = ''+ @nYear + "-04-01"
			@cEndDate = ''+ @nYear + "-06-30"
		case "Q3"
			@cStartDate = ''+ @nYear + "-07-01"
			@cEndDate = ''+ @nYear + "-09-30"
		case "Q4"
			@cStartDate = ''+ @nYear + "-10-01"
			@cEndDate = ''+ @nYear + "-12-31"
		other
			StzRaise("Invalid quarter: " + @cQuarter)
		end

	def _initializeMonth(nYear, nMonth)
		@nYear = nYear
		@nMonth = nMonth
		@cStartDate =  ''+ @nYear + "-" +
			PadLeftXT(''+ nMonth, 2, "0") + "-01"
			
		# Calculate last day of month
		aDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
		
		# Check for leap year
		if (nYear % 4 = 0 and nYear % 100 != 0) or (nYear % 400 = 0)
			aDaysInMonth[2] = 29
		ok
		
		nLastDay = aDaysInMonth[nMonth]
		@cEndDate = ''+ @nYear + "-" +
			PadLeftXT(''+ nMonth, 2, "0") + "-" +
			PadLeftXT(''+ nLastDay, 2, "0")

	def _initializeFromList(aParams)
		@oLocale = _setupLocale("")
		cStart = ""
		cEnd = ""
		nYear = 0
		nMonth = 0
		cQuarter = ""
		
		nLen = len(aParams)
		
		# Check if first element is a number (year)
		if isNumber(aParams[1])
			nYear = aParams[1]
			
			# Check second element
			if nLen >= 2
				if isNumber(aParams[2])
					# [2024, 10] format - year and month
					nMonth = aParams[2]
					_initializeMonth(nYear, nMonth)
					return
				but isString(aParams[2])
					cValue = upper(aParams[2])
					# Check if it's a quarter like "Q3"

					if cValue[1] = "Q"
						_parseQuarterString('' + nYear + "-" + cValue)
						return
					ok
				ok
			else
				# Just year
				_initializeYear(nYear)
				return
			ok
		ok
		
		# Handle named parameters format: [["Start", "2024-10-01"], ["End", "2024-10-31"]]
		i = 1
		while i <= nLen
			if isList(aParams[i]) and len(aParams[i]) = 2
				cKey = "" + lower(aParams[i][1])
				cValue = "" + aParams[i][2]
				
				if cKey = "start" or cKey = "from"
					cStart = cValue
				but cKey = "end" or cKey = "to"
					cEnd = cValue
				but cKey = "year"
					nYear = val(cValue)
				but cKey = "month"
					nMonth = val(cValue)
				but cKey = "quarter"
					cQuarter = upper(cValue)
				but cKey = "lLocale"
					@oLocale = _setupLocale(cValue)
				ok
			ok
			i++
		end
		
		# Apply initialization logic based on collected params
		if cStart != '' and cEnd != ""
			@cStartDate = cStart
			@cEndDate = cEnd
		but cQuarter != ""
			_parseQuarterString('' + nYear + "-" + cQuarter)
		but nYear > 0 and nMonth > 0
			_initializeMonth(nYear, nMonth)
		but nYear > 0
			_initializeYear(nYear)
		ok

	def _setupLocale(pLocale)
		if isString(pLocale) and pLocale != ""
			return pLocale  # For now, store as string
		ok
		return "C"

	def _monthNameToNumber(cName)
		aMonths = [ "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
			"JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER" ]
		nPos = find(aMonths, upper(cName))
		return nPos

	def _dayNameToNumber(cName)
		aDays = [ "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY" ]
		nPos = find(aDays, upper(cName))
		return nPos
	
	def _numberToDayName(nDay)
		aDays = [ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" ]
		if nDay >= 1 and nDay <= 7
			return aDays[nDay]
		ok
		return ""

	def _dayOfYear(nMonth, nDay, nYear)
		aDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
		
		if (nYear % 4 = 0 and nYear % 100 != 0) or (nYear % 400 = 0)
			aDaysInMonth[2] = 29
		ok
		
		nTotal = 0
		for i = 1 to nMonth - 1
			nTotal += aDaysInMonth[i]
		next
		
		return nTotal + nDay

	def _countLeapYears(nYear)
		nYear--
		return floor(nYear / 4) - floor(nYear / 100) + floor(nYear / 400)

	def _toDateString(pDate)
		if isString(pDate)
			return pDate
		ok
		return "" + pDate

	# Boundary accessors
	def Start()
		return @cStartDate
	
	def StartQ()
		return @cStartDate  # String-first, so Q version also returns string
	
	def End_()
		return @cEndDate
	
	def EndQ()
		return @cEndDate
	
	def Year()
		return @nYear
	
	def MonthNumber()
		return @nMonth
	
	def MonthName()
		if @nMonth > 0 and @nMonth <= 12
			aMonths = [ "January", "February", "March", "April", "May", "June",
				"July", "August", "September", "October", "November", "December" ]
			return aMonths[@nMonth]
		ok
		return ""
	
	def QuarterNumber()
		if @cQuarter != ""
			return val(right(@cQuarter, 1))
		ok
		return 0
	
		def QuarterN()
			return This.QuarterNumber()

	def TotalDays()
		return _daysDifference(@cStartDate, @cEndDate) + 1
	
		def DaysN()
			return This.TotalDays()

		def NumberOfDays()
			return This.TotalDays()

		def HowManyDays()
			return This.TotalDays()

		def CountDays()
			return This.TotalDays()

	def ContainsDays()
		return This.TotalDays() > 0

		def HasDays()
			return This.TotalDays() > 0

	def TotalWeeks()
		return ceil(This.TotalDays() / 7.0)
	
		def WeeksN()
			return This.TotalWeeks()

		def NumberOfWeeks()
			return This.TotalWeeks()

		def HowManyWeeks()
			return This.TotalWeeks()

		def CountWeeks()
			return This.TotalWeeks()

	def ContainsWeeks()
		return This.TotalWeeks() > 0

		def HasWeeks()
			return This.TotalWeeks() > 0

	def Content()
		aResult = [
			[:Start, This.Start()],
			[:End, This.End_()],
			[:Year, @nYear],
			[:Month, @nMonth],
			[:Quarter, @cQuarter],
			[:TotalDays, This.TotalDays()],
			[:WorkingDays, This.WorkingDaysN()],
			[:Holidays, @aHolidays],
			[:BusinessHours, [ [:From, @cBusinessStart], [:To, @cBusinessEnd] ]],
			[:Breaks, @aBreaks]
		]
		return aResult

	# Working days configuration
	def SetWorkingDays(pDays)
		if isString(pDays) and upper(pDays) = "DEFAULT"
			@aWorkingDays = [1, 2, 3, 4, 5]  # Mon-Fri
		but isList(pDays)
			@aWorkingDays = []
			nLen = len(pDays)
			for i = 1 to nLen
				cDay = upper("" + pDays[i])
				nDayNum = _dayNameToNumber(cDay)
				if nDayNum > 0
					@aWorkingDays + nDayNum
				ok
			next
		ok
	
		This.InvalidateCache()

	def ContainsWorkingDays()
		return len(@aWorkingDays) > 0

		def HasWorkingDays()
			return len(@aWorkingDays) > 0

	def WorkingDaysN()
		return len(@aWorkingDays)

		def NumberOfWorkingDays()
			return len(@aWorkingDays)

		def HowManyWorkingDays()
			return len(@aWorkingDays)

		def CountWorkingDays()
			return len(@aWorkingDays)

	def IsWorkingDay(pDate)
		cDate = _toDateString(pDate)
		# Get day of week number (1-7, where 1=Monday, 7=Sunday)
		nDayOfWeek = _getDayOfWeek(cDate)
		
		if len(@aWorkingDays) = 0
			SetWorkingDays("DEFAULT")
		ok
		
		return find(@aWorkingDays, nDayOfWeek) > 0
	
	def _getDayOfWeek(cDate)
		return StzDateQ(cDate).DayOfWeekN()

	def FirstWorkingDay()
		cDate = @cStartDate
		while not This.IsWorkingDay(cDate)
			cDate = _getNextDay(cDate)
		end
		return cDate
	
	def LastWorkingDay()
		cDate = @cEndDate
		while not This.IsWorkingDay(cDate)
			cDate = _getPreviousDay(cDate)
		end
		return cDate

	def  WorkingDaysBetween(pStart, pEnd)
		cStart = _toDateString(pStart)
		cEnd = _toDateString(pEnd)
		aResult = []
		
		nLen = len(@aWorkingDays)
		for i = 1 to nLen
			oWorkingDayDate = new stzDate(@aWorkingDays[i][1])
			if oWorkingDayDate >= cStart and oWorkingDayDate <= cEnd
				aResult + @aWorkingDays[i]
			ok
		next
		
		return aResult

	def WorkingDaysBetweenN(pStart, pEnd)
		return len(This.WorkingDaysBetween(pStart, pEnd))

		def NumberOfWorkingDaysBetween(pStart, pEnd)
			return This.WorkingDaysBetweenN(pStart, pEnd)

		def HowManyWorkingDaysBetween(pStart, pEnd)
			return This.WorkingDaysBetweenN(pStart, pEnd)

		def CountWorkingDaysBetween(pStart, pEnd)
			return This.WorkingDaysBetweenN(pStart, pEnd)

	def ContainsWorkingDaysBetween(pStart, pEnd)
		return len(This.WorkingDaysBetween(pStart, pEnd)) > 0

		def HasWorkingDaysBetween(pStart, pEnd)
			return len(This.WorkingDaysBetween(pStart, pEnd))

	# Holiday management
	def AddHoliday(pHolidayOrLabel, pName)
		if isList(pHolidayOrLabel)
			nLen = len(pHolidayOrLabel)
			for i = 1 to nLen
				if isList(pHolidayOrLabel[i]) and len(pHolidayOrLabel[i]) = 2
					@aHolidays + pHolidayOrLabel[i]
				ok
			next
		but isString(pHolidayOrLabel)
			if pName = ""
				pName = "Holiday"
			else
				pName = "" + pName
			ok
			cDate = _toDateString(pHolidayOrLabel)
			@aHolidays + [cDate, pName]
		ok
	
		This.InvalidateCache()

	def ContainsHolidays()
		return len(@aHolidays) > 0

		def HasHolidays()
			return len(@aHolidays)

	def IsHoliday(pDate)
		cDate = _toDateString(pDate)
		nLen = len(@aHolidays)
		for i = 1 to nLen
			if @aHolidays[i][1] = cDate
				return TRUE
			ok
		next
		return FALSE
	
	def HolidayName(pDate)
		cDate = _toDateString(pDate)
		nLen = len(@aHolidays)
		for i = 1 to nLen
			if @aHolidays[i][1] = cDate
				return @aHolidays[i][2]
			ok
		next
		return ""

	def Holidays()
		return @aHolidays
	
	def HolidaysN()
		return len(@aHolidays)

		def NumberOfHolidays()
			return len(@aHolidays)

		def CountHolidays()
			return len(@aHolidays)

	def HolidaysBetween(pStart, pEnd)
		cStart = _toDateString(pStart)
		cEnd = _toDateString(pEnd)
		aResult = []
		
		nLen = len(@aHolidays)
		for i = 1 to nLen
			oHolidayDate = new stzDate(@aHolidays[i][1])
			if oHolidayDate >= cStart and oHolidayDate <= cEnd
				aResult + @aHolidays[i]
			ok
		next
		
		return aResult

	def HolidaysBetweenN(pStart, pEnd)
		return len(This.HolidaysBetween(pStart, pEnd))

		def NumberOfHolidaysBetween(pStart, pEnd)
			return len(This.HolidaysBetween(pStart, pEnd))

		def CountHolidaysBetween(pStart, pEnd)
			return len(This.HolidaysBetween(pStart, pEnd))

	def ContainsHolidaysBetween(pStart, pEnd)
		return len(This.HolidaysBetween(pStart, pEnd)) > 0

		def HasHolidaysBetween(pStart, pEnd)
			return len(This.HolidaysBetween(pStart, pEnd)) > 0

	# Business hours
	def SetBusinessHours(pStart, pEnd)
		if isList(pStart)
			if len(pStart) >= 2
				@cBusinessStart = "" + pStart[2]
			ok
			if isList(pEnd) and len(pEnd) >= 2
				@cBusinessEnd = "" + pEnd[2]
			ok
		else
			@cBusinessStart = "" + pStart
			@cBusinessEnd = "" + pEnd
		ok
	
		This.InvalidateCache()

	def BusinessHours()
		return [ [:From, @cBusinessStart], [:To, @cBusinessEnd] ]
	
	def ContainsBusinessHours()
		return @cBusinessStart != '' and @cBusinessEnd = ""

		def HasBusinessHours()
			return @cBusinessStart != '' and @cBusinessEnd = ""

	# Breaks management
	def AddBreak(pBreakStart, pBreakEnd, pLabel)
		if isList(pBreakStart)
			nLen = len(pBreakStart)
			for i = 1 to nLen
				if isList(pBreakStart[i]) and len(pBreakStart[i]) >= 2
					@aBreaks + pBreakStart[i]
				ok
			next
		else
			if pLabel = NULL
				pLabel = "Break"
			else
				pLabel = "" + pLabel
			ok
			@aBreaks + ["" + pBreakStart, "" + pBreakEnd, pLabel]
		ok
	
		This.InvalidateCache()

	def Breaks()
		return @aBreaks

	def BreaksN()
		return len(@aBreaks)

		def NumberOfBreaks()
			return len(@aBreaks)

		def CountBreaks()
			return len(@aBreaks)

	def ContainsBreaks()
		return len(@aBreaks) > 0

		def HasBreaks()
			return len(@aBreaks)

	def  BreaksBetween(pStart, pEnd)
		cStart = _toDateString(pStart)
		cEnd = _toDateString(pEnd)
		aResult = []
		
		nLen = len(@aBreaks)
		for i = 1 to nLen
			oBreakDate = new stzDate(@aBreaks[i][1])
			if oBreakDate >= cStart and oBreakDate <= cEnd
				aResult + @a Breaks[i]
			ok
		next
		
		return aResult

	def BreaksBetweenN(pStart, pEnd)
		return len(This.BreaksBetween(pStart, pEnd))

		def HowManyBreaksBetween(pStart, pEnd)
			return len(This.BreaksBetween(pStart, pEnd))

		def CountBreaksBetween(pStart, pEnd)
			return len(This.BreaksBetween(pStart, pEnd))

	def ContainsBreaksBetween(pStart, pEnd)
		return len(This. reaksBetween(pStart, pEnd)) > 0

		def HasBreaksBetween(pStart, pEnd)
			return len(This.BreaksBetween(pStart, pEnd))

	# Capacity calculations

	def AvailableHours()
		stzraise("Not yet implemented!")
		#TODO// Returns a list of datetime strings

	def AvailableHoursN()
		# Return cached value if range hasn't changed
		if @cCachedStart = @cStartDate and @cCachedEnd = @cEndDate and @nCachedAvailableHours >= 0
			return @nCachedAvailableHours
		ok
		
		return This.AvailableHoursBetweenN(This.Start(), This.End_())
		
		def HowManyAvailableHoursB()
			return This.AvailableHoursN()

		def CountAvailableHours()
			return This.AvailableHoursN()

	def ContainsAvailableHours()
		return This.AvailableHoursN() > 0
	
		def HasAvailableHours()
			return This.AvailableHoursN() > 0

	def AvailableHoursBetween(pStart, pEnd)
		stzraise("Not yet implemented!")
		#TODO// Returns a list of datetime strings

	def AvailableHoursBetweenN(pStart, pEnd)
		cStart = _toDateString(pStart)
		cEnd = _toDateString(pEnd)
		nTotalHours = 0
		nDays = StzDateQ(cStart).DaysToDate(cEnd)
		
		cDate = cStart
		for i = 0 to nDays
			if This.IsWorkingDay(cDate) and not This.IsHoliday(cDate)
				nDayHours = This.AvailableHoursOnN(cDate)
				nTotalHours += nDayHours
			ok
			cDate = _getNextDay(cDate)
		next
		
		# Cache result
		@cCachedStart = This.Start()
		@cCachedEnd = This.End_()
		@nCachedAvailableHours = nTotalHours
		
		return nTotalHours
	
	def HowManyAvailableHoursBetween(pStart, pEnd)
		return This.AvailableHoursBetweenN(pStart, pEnd)

	def CountAvailableHoursBetween(pStart, pEnd)
		return len(This.BreaksBetween(pStart, pEnd))

	def ContainsAvailableHoursBetween(pStart, pEnd)
		return This.AvailableHoursBetweenN(pStart, pEnd) > 0
	
		def HasAvailableHoursBetween(pStart, pEnd)
			return This.AvailableHoursBetween(pStart, pEnd) > 0

	def AvailableHoursOn(pDate)
		stzraise("Not yet implemented!")
		#TODO// Returns a list of datetime strings

	def AvailableHoursOnN(pDate)
		if This.IsHoliday(pDate)
			return 0
		ok
		if not This.IsWorkingDay(pDate)
			return 0
		ok
		
		# Parse times: "09:00:00" format
		aStartParts = @split(@cBusinessStart, ":")
		aEndParts = @split(@cBusinessEnd, ":")
		
		nStartMinutes = val(aStartParts[1]) * 60 + val(aStartParts[2])
		nEndMinutes = val(aEndParts[1]) * 60 + val(aEndParts[2])
		nTotalMinutes = nEndMinutes - nStartMinutes
		
		nLen = len(@aBreaks)
		for i = 1 to nLen
			aBreakStart = @split(@aBreaks[i][1], ":")
			aBreakEnd = @split(@aBreaks[i][2], ":")
			
			nBreakStartMinutes = val(aBreakStart[1]) * 60 + val(aBreakStart[2])
			nBreakEndMinutes = val(aBreakEnd[1]) * 60 + val(aBreakEnd[2])
			nBreakMinutes = nBreakEndMinutes - nBreakStartMinutes
			
			nTotalMinutes -= nBreakMinutes
		next
		
		return floor(nTotalMinutes / 60.0)
	
	def HowManyAvailableHoursOn(pDate)
		return This.AvailableHoursOnN(pDate)

	def CountAvailableHoursOn(pDate)
		return This.AvailableHoursOnN(pDate)

	def ContainsAvailableHoursOn(pDate)
		return This.AvailableHoursOn(pDate) > 0
	
		def HasAvailableHoursOn(pDate)
			return This.AvailableHoursOn(pDate) > 0

	# Days

	def AvailableDaysN()
		if @cCachedStart = @cStartDate and @cCachedEnd = @cEndDate and @nCachedAvailableDays >= 0
			return @nCachedAvailableDays
		ok
		
		nDays = 0
		nTotalDays = This.TotalDays()
		cDate = @cStartDate
		
		for i = 1 to nTotalDays
			if This.IsWorkingDay(cDate) and not This.IsHoliday(cDate)
				nDays++
			ok
			cDate = _getNextDay(cDate)
		next
		
		# Cache result
		@nCachedAvailableDays = nDays
		
		return nDays

	def AvailableDays()

		acResult = []
		
		nTotalDays = This.TotalDays()
		cDate = @cStartDate
		
		for i = 1 to nTotalDays
			if This.IsWorkingDay(cDate) and not This.IsHoliday(cDate)
				acResult + cDate
			ok
			cDate = _getNextDay(cDate)
		next
		
		return acResult

	def HowManyAvailableDays()
		return This.AvailableDaysN()

	def CountAvailableDays()
		return This.AvailableDaysN()

	def ContainsAvailableDays()
		return This.AvailablesDaysN() > 0

		def HasAvailableDays()
			return This.AvailableDaysN() > 0

	def AvailableDaysBetween(pStart, pEnd) #TODO
		raise("Not yet implemented!")
		# returns a list of dates
	
	def AvailableDaysBetweenN(pStart, pEnd)
		return len(This.AvailabelDaysBetween(pStart, pEnd))

	def HowManyAvailableDaysBetween(pStart, pEnd)
		return This.AvailableDaysBetweenN(pStart, pEnd)

	def CountAvailableDaysBetween(pStart, pEnd)
		return this.AvailableDaysBetweenN(pStart, pEnd)

	def ContainsAvailableDaysBetween(pStart, pEnd)
		return This.AvailableDaysBetweenN(pStart, pEnd) > 0

		def HasAvailableDaysBetween(pStart, pEnd)
			return This.AvailableDaysBetweenN(pStart, pEnd) > 0

	#--

	def AvailableWeeks()
		stzraise("Not yet implemented!")
		#TODO// Returns a list of pairs of dates of end and start of weeks

	def AvailableWeeksN()
		return ceil(This.AvailableDaysN() / 5.0)
	
		def HowManyAvailableWeeks()
			return This.AvailableWeeksN()

		def CountAvailableWeeks()
			return This.AvailableWeeksN()

	def ContainsAvailableWeeks()
		return This.AvailableWeeksN() > 0

		def HasAvailableWeeks()
			return This.AvailableWeeksN() > 0

	def AvailableMinutesN()
		return This.AvailableHoursN() * 60
	
		def AvailableMinutes()
			#NOTE// Exceptionnaly we semantically allow it to return
			# a number because it is what we really expect when
			# we ask for available minutes

			return This.AvailableHoursN() * 60

	#-- Checking Fitness of a date-duration in the calendar

	def CanFit(pDate, pDuration)
		nDuration = val("" + pDuration)
		nAvailableHours = This.AvailableHoursOnN(pDate)
		
		return nDuration <= nAvailableHours
	
	def FirstAvailableSlot(pDuration)
		nRequiredHours = val("" + pDuration)
		nDays = This.TotalDays()
		cDate = @cStartDate
		
		for i = 1 to nDays
			if This.CanFit(cDate, nRequiredHours)
				cStart = cDate + " " + @cBusinessStart
				# Add hours to business start time
				nEndMinutes = _timeToMinutes(@cBusinessStart) + (nRequiredHours * 60)
				cEnd = cDate + " " + _minutesToTime(nEndMinutes)
				return [cStart, cEnd]
			ok
			cDate = _getNextDay(cDate)
		next
		
		return []

	def ConsecutiveWorkingDaysAvailable(pDate)
		if isList(pDate) and StzListQ(pDate).IsStartingFromNamedParam()
			pDate = pDate[2]
		ok

		aResult = []

		cDate = _toDateString(pDate)
		nDays = This.TotalDays()
		nStartDay = _daysDifference(@cStartDate, cDate)
		
		for i = nStartDay to nDays
			if This.IsWorkingDay(cDate) and not This.IsHoliday(cDate)
				aResult + cDate
			else
				exit
			ok
			cDate = _getNextDay(cDate)
		next
		
		return aResult

		#< @FunctionAlternativeForms

		def ConsecutiveAvailableWorkingDays(pDate)
			return This.ConsecutiveWorkingDaysAvailable(pDate)

		def AvailableConsecutiveWorkingDays(pDate)
			return This.ConsecutiveWorkingDaysAvailable(pDate)

		#--

		def ConsecutiveWorkingDaysAvailableStartingFrom(pDate)
			return This.ConsecutiveWorkingDaysAvailable(pDate)

		def ConsecutiveAvailableWorkingDaysStartingFrom(pDate)
			return This.ConsecutiveWorkingDaysAvailable(pDate)

		def AvailableConsecutiveWorkingDaysStartingFrom(pDate)
			return This.ConsecutiveWorkingDaysAvailable(pDate)

		#>

	def ConsecutiveWorkingDaysAvailableN(pDate)
		return len(This.ConsecutiveWorkingDaysAvailable(pDate))

		#< @FunctionAlternativeForms

		def ConsecutiveAvailableWorkingDaysN(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def AvailableConsecutiveWorkingDaysN(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		#--

		def ConsecutiveWorkingDaysAvailableStartingFromN(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def ConsecutiveAvailableWorkingDaysStartingFromN(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def AvailableConsecutiveWorkingDaysStartingFromN(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		#==

		def HowManyConsecutiveWorkingDaysAvailable(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def HowManyConsecutiveAvailableWorkingDays(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def HawManyAvailableConsecutiveWorkingDays(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		#--

		def HowManyConsecutiveWorkingDaysAvailableStartingFrom(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def HowManyConsecutiveAvailableWorkingDaysStartingFrom(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def HowManyAvailableConsecutiveWorkingDaysStartingFrom(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		#==

		def CountConsecutiveWorkingDaysAvailable(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def CountManyConsecutiveAvailableWorkingDays(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def CountManyAvailableConsecutiveWorkingDays(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		#--

		def CountConsecutiveWorkingDaysAvailableStartingFrom(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def HawManyConsecutiveAvailableWorkingDaysStartingFrom(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		def CountAvailableConsecutiveWorkingDaysStartingFrom(pDate)
			return This.ConsecutiveWorkingDaysAvailableN(pDate)

		#>

	# Range info

def RangeInfo(pStart, pEnd)
	cStart = _toDateString(pStart)
	cEnd = _toDateString(pEnd)
	
	nTotalDays = StzDateQ(cStart).DaysToDate(cEnd) + 1
	nWorkingDays = 0
	nHolidays = 0
	nWeekends = 0
	nAvailableHours = 0
	aOverlappingEvents = []
	
	cDate = cStart
	for i = 1 to nTotalDays
		if This.IsHoliday(cDate)
			nHolidays++
		but not This.IsWorkingDay(cDate)
			nWeekends++
		else
			nWorkingDays++
			nAvailableHours += This.AvailableHoursOnN(cDate)
		ok
		cDate = _getNextDay(cDate)
	next
	
	aResult = [
		[ "startDate", cStart],
		[ "endDate", cEnd],
		[ "totalDays", nTotalDays],
		[ "workingDays", nWorkingDays],
		[ "weekendDays", nWeekends],
		[ "holidays", nHolidays],
		[ "availableHours", nAvailableHours],
		[ "overlappingEvents", aOverlappingEvents]
	]
	
	return aResult

	def SectionInfo(pStart, pEnd)
		return This.RangeInfo(pStart, pend)

	def PeriodInfo(pStart, pEnd)
		return This.RangeInfo(pStart, pend)

	def SpanInfo(pStart, pEnd)
		return This.RangeInfo(pStart, pend)

	def RangeXT(pStart, pEnd)
		return This.RangeInfo(pStart, pend)

	def SpanXT(pStart, pEnd)
		return This.RangeInfo(pStart, pend)

	def PeriodXT(pStart, pEnd)
		return This.RangeInfo(pStart, pend)


	#------------------------------------------#
	#  NAVIGATING THE CALENDAR BACK AND FORTH  #
	#------------------------------------------#

	# Navigating to next/previous Day

	def NextDay()
		stzraise("Not yet implemented!")
		#TODO// See how meonths and years are implemented
		#NOTE// Currently the class does not save the current day in the calendar


	def GoToNextDay()
		stzraise("Not yet implemented!")
	
		def GotoNextDayQ()
			This.GotoNextDay()
			return This

	def PreviousDay()
		stzraise("Not yet implemented!")

	def GoToPreviousDay()
		stzraise("Not yet implemented!")
	
		def GotoPreviousDayQ()
			This.GotoPreviousDay()
			return THis

	# Navigating to next/previous year

	def Next_() # Does not naviaget just returns the next month
		_nMonth_ = @nMonth
		_nYear_ = @nYear

		if _nMonth_ > 0
			_nMonth_++
			if _nMonth_ > 12
				_nYear_++
			ok
			return StzDateQ(''+ _nYear_ + "-" + _nMonth_ + "-01").MonthName()
		ok

		def NextMonth()
			return This.Next_()
	
	def GotoNextMonth()
		if @nMonth > 0
			@nMonth++
			if @nMonth > 12
				@nYear++
			ok
			_initializeMonth(@nYear, @nMonth)
		ok
	
		def GotoNextMonthQ()
			This.GotoNextMonth()
			return This

		def GoToNext()
			This.GoNextMonth()

			def GotoNextQ()
				return This.GotoNextMonthQ()


	def Previous() # Does not naviaget just returns the next month
		_nMonth_ = @nMonth
		_nYear_ = @nYear

		if _nMonth_ > 0
			_nMonth_--
			if _nMonth_ < 1
				_nMonth_ = 12
				_nYear_--
			ok
			return StzDateQ('' + @nYear+ "-" + _nMonth_ + "-01").MonthName()
		ok

		def PreviousMonth()
			return This.Previous()
	
	def GoToPreviousMonth()
		if @nMonth > 0
			@nMonth--
			if @nMonth < 1
				@nMonth = 12
				@nYear--
			ok
			_initializeMonth(@nYear, @nMonth)
		ok
	
		def GotoPreviousMonthQ()
			This.GotoPreviousMonth()
			return This

		def GoToPrevious()
			This.GoToPreviousMonth()

			def GoToPreviousQ()
				return This.GotoPreviousMonthQ()

	# Navigating to next/previous year

	def NextYear()
		_nYear_ = @nYear
		return _nYear_ + 1

	def GoToNextYear()
		@nYear++
		@cStartDate = ''+ @nYear + "-01-01"
		@cEndDate = ''+ @nYear + "-12-31"
	
		def GotoNextYearQ()
			This.GotoNextYear()
			return This

	def PreviousYear()
		_nYear_ = @nYear
		return  _nYear_ - 1

	def GoToPreviousYear()
		@nYear--
		@cStartDate = ''+ @nYear + "-01-01"
		@cEndDate = ''+ @nYear + "-12-31"
	
		def GotoPreviousYearQ()
			This.GotoPreviousYear()
			return THis

	# Going to a give date

	def GoTo(pDate)
		stzraise("Not yet implemented!")

	# Getting info
	
	def Current()
		if @nMonth > 0
			return This.MonthName() + " " + @nYear
		but @cQuarter != ""
			return @cQuarter + " " + @nYear
		ok
		return This.Start() + " to " + This.End_()


	def IsToday()
		cToday = Today()
		oToday = new stzDate(cToday)
		oStartDate = new stzDate(@cStartDate)
		return (oStartDate <= cToday and oToday <= @cEndDate)

	# Date queries

	def FirstDayOfWeek()
		cDate = @cStartDate
		oDate = new stzDate(cDate)
		nDayOfWeek = oDate.DayOfWeek()
		
		# Go back to Monday of this week
		nDaysBack = nDayOfWeek - 1
		for i = 1 to nDaysBack
			cDate = _getPreviousDay(cDate)
		next
		
		return cDate
	
	def LastDayOfWeek()
		cDate = @cStartDate
		oDate = new stzDate(cDate)
		nDayOfWeek = oDate.DayOfWeek()
		
		# Go forward to Sunday of this week
		nDaysForward = 7 - nDayOfWeek
		for i = 1 to nDaysForward
			cDate = _getNextDay(cDate)
		next
		
		return cDate

	def WorkingDays()
		aResult = []
		cDate = @cStartDate
		nDays = This.TotalDays()
		
		for i = 1 to nDays
			if This.IsWorkingDay(cDate)
				aResult + cDate
			ok
			cDate = _getNextDay(cDate)
		next
		
		return aResult
	
	def Weekends()
		aResult = []
		cDate = @cStartDate
		nDays = This.TotalDays()
		
		for i = 1 to nDays
			if not This.IsWorkingDay(cDate)
				aResult + cDate
			ok
			cDate = _getNextDay(cDate)
		next
		
		return aResult
	
	def WeekendsN()
		return len(This.Weekends())

		def HowManyWeekends()
			return THis.WeekendsN()

		def CountWeekends()
			return THis.WeekendsN()

	def ContainsWeekends()
		return len(This.Weekends()) > 0

		def HasWeekends()

	def WeekendsBetween(pStart, pEnd)
		stzraise("Not yet implemented!")
		#TODO// Returns a list days as datestrings

	def WeekendsBetweenN(pStart, pEnd)
		return len(This.WeekendsBetween(pStart, pEnd))

		def HowManyWeekendsBetween(pStart, pEnd)
			return This.WeekendsBetweenN(pStart, pEnd)

		def CountWeekendsBetween(pStart, pEnd)
			return This.WeekendsBetweenN(pStart, pEnd)


	# FIXED: FreeDays() - returns working days with no breaks scheduled
	# A "free day" is a working day that's not a holiday and has no breaks
	def FreeDays()
		aResult = []
		cDate = @cStartDate
		nDays = This.TotalDays()
		
		for i = 1 to nDays
			if This.IsWorkingDay(cDate) and not This.IsHoliday(cDate)
				aResult + cDate
			ok
			cDate = _getNextDay(cDate)
		next
		
		return aResult
	
	def DateInfo(pDate)
		cDate = _toDateString(pDate)
		
		aResult = [
			[ "date", cDate],
			[ "isWorkingDay", This.IsWorkingDay(cDate)],
			[ "isHoliday", This.IsHoliday(cDate)],
			[ "availableHours", This.AvailableHoursOnN(cDate)]
		]
		
		return aResult

	# Copy and Clone
	def Copy()
		_oCopy_ = new stzCalendar(This.Start())

		_oCopy_.@cStartDate = This.@cStartDate
		_oCopy_.@cEndDate = This.@cEndDate
		_oCopy_.@aWorkingDays = This.@aWorkingDays
		_oCopy_.@aHolidays = This.@aHolidays
		_oCopy_.@aBreaks = This.@aBreaks
		_oCopy_.@cBusinessStart = This.@cBusinessStart
		_oCopy_.@cBusinessEnd = This.@cBusinessEnd
		_oCopy_.@nYear = This.@nYear
		_oCopy_.@nMonth = This.@nMonth
		_oCopy_.@cQuarter = This.@cQuarter

		return _oCopy_
	
	def Clone()
		return This.Copy()


	  #------------------------#
	 #  TimeLine Integration  #
	#------------------------#

def MarkTimeline(oTimeLine)
	if NOT (isObject(oTimeLine) and ring_classname(oTimeLine) = "stztimeline")
		StzRaise("Incorrect param type! oTimeLine must be a stzTimeLine object.")
	ok
	
	@oTimeline = oTimeLine
	
	oTimelineStart = new stzDateTime(oTimeLine.Start())
	oTimelineEnd = new stzDatetime(oTimeLine.End_())
	
	if oTimelineStart < @cStartDate or oTimelineEnd > @cEndDate
		? "Warning: Timeline extends beyond calendar range"
	ok

def TimelineEventsXT()
	if NOT (isObject(oTimeLine) and ring_classname(oTimeLine) = "stztimeline")
		StzRaise("Incorrect param type! oTimeLine must be a stzTimeLine object.")
	ok
	
	aResult = [[:LABEL, :COUNT, :DURATION, :CONFLICTS]]
	
	aPoints = @oTimeline.Points()
	aSpans = @oTimeline.Spans()
	aBlockedSpans = @oTimeline.BlockedSpans()
	
	nPointCount = len(aPoints)
	if nPointCount > 0
		aResult + ["Points", nPointCount, "—", 0]
	ok
	
	nSpanCount = len(aSpans)
	if nSpanCount > 0
		aResult + ["Spans", nSpanCount, "—", 0]
	ok
	
	nBlockedCount = len(aBlockedSpans)
	if nBlockedCount > 0
		aResult + ["Blocked", nBlockedCount, "—", 0]
	ok
	
	return aResult

def HasTimeline()
	if isString(@oTimeLine) and @oTimeLine = ""
		return 0
	but isObject(@oTimeLine) and ring_classname(@oTimeLine) = "stztimeline"
		return 1
	ok

	def ContainsTimeline()
		return This.HasTimeLine()

	def HasATimeLine()
		return This.HasTimeLine()

	def ContainsATimeLine()
		return This.HasTimeLine()

def StzTimeLineObject()
	return @oTimeLine

	def TimeLineObject()
		return @oTimeLine

def TimeLinePoints()
	if This.HasATimeLine()
		return This.TimeLineObject().Points()
	else
		return []
	ok

	def TimeLineMoments()
		return This.TimeLinePoints()

def ContainsTimeLinePoints()
	return len(This.TimeLinePoints()) > 0

	def ContainsTimeLineMoments()
		return THis.ContainsTimeLinePoints()

	def HasTimeLinePoints()
		return THis.ContainsTimeLinePoints()

	def HasTimeLineMoments()
		return THis.ContainsTimeLinePoints()

def TimeLineSpans()
	if This.HasATimeLine()
		return This.TimeLineObject().Spans()
	else
		return []
	ok

	def TimeLinePeriods()
		return This.TimeLineSpans()

def ContainsTimeLineSpans()
	return len(This.TimeLineSpans()) > 0

	def ContainsTimeLinePeriods()
		return THis.ContainsTimeLineSpans()

	def HasTimeLineSpans()
		return THis.ContainsTimeLineSpans()

	def HasTimeLinePeriods()
		return THis.ContainsTimeLineSpans()





def TimeLineEvents()
	if This.HasATimeLine()
		return [
			:Points = This.TimeLineObject().Points(),
			:Spans = This.TimeLineObject().Spans()
		]

	else
		return []
	ok

	def TimeLinePointsAndSpans()
		return This.TimeLineEvents()

	def TimeLineSpansAndPoints()
		return This.TimeLineEvents()

	def TimeLineMomentsAndPeriods()
		return This.TimeLineEvents()

	def TimeLinePeriodsAndMoments()
		return This.TimeLineEvents()

	def TimeLinePointsAndPeriods()
		return This.TimeLineEvents()

	def TimeLinePeriodsAndPoints()
		return This.TimeLineEvents()

	def TimeLineMomentsAndSpans()
		return This.TimeLineEvents()

	def TimeLinespansAndMoments()
		return This.TimeLineEvents()

def ContainsTimeLineEvents()
	return len(This.TimeLineEvents()) > 0

	#< @FunctionAlternativeForms

	def ContainsTimeLinePointsOrSpans()
		return This.ContainsTimeLineEvents()

	def ContainsTimeLineSpansOrPoints()
		return This.ContainsTimeLineEvents()

	def ContainsTimeLineMomentsOrPeriods()
		return This.ContainsTimeLineEvents()

	def ContainsTimeLinePeriodsOrMoments()
		return This.ContainsTimeLineEvents()

	def ContainsTimeLinePointsOrPeriods()
		return This.ContainsTimeLineEvents()

	def ContainsTimeLinePeriodsOrPoints()
		return This.ContainsTimeLineEvents()

	def ContainsTimeLineMomentsOrSpans()
		return This.ContainsTimeLineEvents()

	def ContainsTimeLinespansOrMoments()
		return This.ContainsTimeLineEvents()


	#--

	def HasTimeLineEvents()
		return This.ContainsTimeLineEvents()

	def HasTimeLinePointsOrSpans()
		return This.HasTimeLineEvents()

	def HasTimeLineSpansOrPoints()
		return This.HasTimeLineEvents()

	def HasTimeLineMomentsOrPeriods()
		return This.HasTimeLineEvents()

	def HasTimeLinePeriodsOrMoments()
		return This.HasTimeLineEvents()

	def HasTimeLinePointsOrPeriods()
		return This.HasTimeLineEvents()

	def HasTimeLinePeriodsOrPoints()
		return This.HasTimeLineEvents()

	def HasTimeLineMomentsOrSpans()
		return This.HasTimeLineEvents()

	def HasTimeLinespansOrMoments()
		return This.HasTimeLineEvents()

	#>


def ConflictsWith(oTimeLine)
	if NOT (isObject(oTimeLine) and ring_classname(oTimeLine) = "stztimeline")
		StzRaise("Incorrect param type! oTimeLine must be a stzTimeLine object.")
	ok
	
	aPoints = oTimeLine.Points()
	aSpans = oTimeLine.Spans()
	
	nLen = len(aPoints)
	for i = 1 to nLen
		cDate = aPoints[i][2]
		aParts = @split(cDate, " ")
		cDateOnly = aParts[1]
		
		if This.IsHoliday(cDateOnly) or not This.IsWorkingDay(cDateOnly)
			return TRUE
		ok
	next
	
	nLen = len(aSpans)
	for i = 1 to nLen
		cStart = aSpans[i][2]
		cEnd = aSpans[i][3]
		
		aParts = @split(cStart, " ")
		cStartDate = aParts[1]
		
		aParts = @split(cEnd, " ")
		cEndDate = aParts[1]
		
		nDays = StzDateQ(cStartDate).DaysToDate(cEndDate)
		cDate = cStartDate
		for j = 0 to nDays
			if This.IsHoliday(cDate) or not This.IsWorkingDay(cDate)
				return TRUE
			ok
			cDate = _getNextDay(cDate)
		next
	next
	
	return FALSE

def ConflictsWithSpan(cLabel, aParams)
	if NOT (isObject(oTimeLine) and ring_classname(oTimeLine) = "stztimeline")
		StzRaise("Incorrect param type! oTimeLine must be a stzTimeLine object.")
	ok
	
	aSpans = @oTimeline.Spans()
	aConflicts = []
	
	nLen = len(aSpans)
	for i = 1 to nLen
		if aSpans[i][1] = cLabel
			cStart = aSpans[i][2]
			cEnd = aSpans[i][3]
			
			aParts = @split(cStart, " ")
			cStartDate = aParts[1]
			
			aParts = @split(cEnd, " ")
			cEndDate = aParts[1]
			
			nDays = StzDateQ(cStartDate).DaysToDate(cEndDate)
			cDate = cStartDate
			for j = 0 to nDays
				if This.IsHoliday(cDate)
					aConflicts + [cDate, "Holiday: " + This.HolidayName(cDate)]
				but not This.IsWorkingDay(cDate)
					aConflicts + [cDate, "Weekend"]
				ok
				cDate = _getNextDay(cDate)
			next
		ok
	next
	
	return aConflicts

	  #-------------------------#
	 #  CONSTRAINT MANAGEMENT  #
	#-------------------------#

def AddConstraint(cName, pConstraint)
	if isString(cName) and isList(pConstraint)
		@aConstraints + [cName, pConstraint]
	ok

def Constraints()
	return @aConstraints

def ApplyConstraints(pDate)
	cDate = _toDateString(pDate)
	nAvailableHours = This.AvailableHoursOnN(cDate)
	
	nLen = len(@aConstraints)
	for i = 1 to nLen
		cConstraintName = @aConstraints[i][1]
		aConstraintDef = @aConstraints[i][2]
		
		# Check constraint type
		if isList(aConstraintDef) and len(aConstraintDef) >= 2
			cType = aConstraintDef[1]
			
			if cType = :Every
				# Format: [:Every, :Wednesday, :From, "14:00", :To, "16:00"]
				cDay = "" + aConstraintDef[2]
				oDate = new stzDate(cDate)
				
				if upper(oDate.DayName()) = upper(cDay)
					if len(aConstraintDef) >= 6
						cFrom = aConstraintDef[4]
						cTo = aConstraintDef[6]
						nConstraintMinutes = _timeWindowMinutes(cFrom, cTo)
						nAvailableHours -= floor(nConstraintMinutes / 60.0)
					ok
				ok
			ok
		ok
	next
	
	return max([0, nAvailableHours])

def _timeWindowMinutes(cStart, cEnd)
	aStartParts = @split(cStart, ":")
	aEndParts = @split(cEnd, ":")
	
	nStartMinutes = val(aStartParts[1]) * 60 + val(aStartParts[2])
	nEndMinutes = val(aEndParts[1]) * 60 + val(aEndParts[2])
	
	return nEndMinutes - nStartMinutes

	  #-----------------------------#
	 #  MULTI-CALENDAR COMPARISON  #
	#-----------------------------#

def CompareWith(oOtherCal)
	if not (isobject(oOtherCal) and ring_classname(oOtherCal) = "stzcalendar")
		StzRaise("Incorrect param type! oOtherCal must be a stzCalendar object.")
	ok
	
	aResult = []
	
	aResult + [ :Metric, This.Current(), oOtherCal.Current(), :Difference ]
	
	nThisDays = This.TotalDays()
	nOtherDays = oOtherCal.TotalDays()
	aResult + ["Total Days", nThisDays, nOtherDays, nThisDays - nOtherDays]
	
	nThisWorking = This.AvailableDaysN()
	nOtherWorking = oOtherCal.AvailableDaysN()
	aResult + ["Working Days", nThisWorking, nOtherWorking, nThisWorking - nOtherWorking]
	
	nThisHours = This.AvailableHoursN()
	nOtherHours = oOtherCal.AvailableHoursN()
	aResult + ["Available Hours", nThisHours, nOtherHours, nThisHours - nOtherHours]
	
	nThisHolidays = len(@aHolidays)
	nOtherHolidays = len(oOtherCal.Holidays())
	aResult + ["Holidays", nThisHolidays, nOtherHolidays, nThisHolidays - nOtherHolidays]
	
	nThisWeeks = This.TotalWeeks()
	nOtherWeeks = oOtherCal.TotalWeeks()
	aResult + ["Total Weeks", nThisWeeks, nOtherWeeks, nThisWeeks - nOtherWeeks]
	
	return aResult

	#< @FunctionFluentForm

	def CompareWithQ(oOtherCal)
		return new stzListQ(oOtherCal)

	def CompareWithQR(oOtherCal, pcReturnType)
		switch pcReturnType
		on :stzList
			return new stzList(This.CompareWith(oOtherCal))

		on :stzListOfLists
			return new stzListOfLists(This.CompareWith(oOtherCal))

		on :stzTable
			return new stzTable(This.CompareWith(oOtherCal))
 
		other
			StzRaise("Insupported return type!")
		off

	#>

	#< @FunctionAlternativeForms

	def CompareTo(oOtherCal)
		return This.CompareWith(oOtherCal)

		def CompareToQ(oOtherCal)
			return This.CompareWithQ(oOtherCal)

		def CompareToQR(oOtherCal, pcReturnType)
			return This.CompareWithQR(oOtherCal, pcReturnType)

	def Compare(oOtherCal)
		if isList(oOtherCal) and StzListQ(oOtherCal).IsToOrWithNamedParam()
			oOtherCal = oOtherCal[2]
		ok

		return This.CompareWith(oOtherCal)

		def CompareQ(oOtherCal)
			return This.CompareWithQ(oOtherCal)

		def CompareQR(oOtherCal, pcReturnType)
			return This.CompareWithQR(oOtherCal, pcReturnType)

	#>

	  #----------------------#
	 #  CACHE INVALIDATION  #
	#----------------------#

def InvalidateCache()
	@nCachedAvailableHours = -1
	@nCachedAvailableDays = -1
	@cCachedStart = ""
	@cCachedEnd = ""


	  #------------------#
	 #  EXPORT METHODS  #
	#------------------#

def ToHash()
	aHash = [
		[:startDate, @cStartDate],
		[:endDate, @cEndDate],
		[:year, @nYear],
		[:month, @nMonth],
		[:quarter, @cQuarter],
		[:totalDays, This.TotalDays()],
		[:workingDays, This.AvailableDaysN()],
		[:availableHours, This.AvailableHoursN()],
		[:workingDaysList, @aWorkingDays],
		[:holidays, @aHolidays],
		[:breaks, @aBreaks],
		[:businessStart, @cBusinessStart],
		[:businessEnd, @cBusinessEnd]
	]
	return aHash

def ToJSON()
	aHash = This.ToHash()
	cJSON = "{"
	nLen = len(aHash)
	
	for i = 1 to nLen
		cKey = "" + aHash[i][1]
		cValue = aHash[i][2]
		
		cJSON += nl + '"' + cKey + '": '
		
		if isString(cValue)
			cJSON += '"' + cValue + '"'
		but isNumber(cValue)
			cJSON += "" + cValue
		but isList(cValue)
			cJSON += _listToJSON(cValue)
		else
			cJSON += '""'
		ok
		
		if i < nLen
			cJSON += ","
		ok
	next
	
	cJSON += nl + "}"
	return cJSON

def _listToJSON(aList)
	cJSON = "["
	nLen = len(aList)
	
	for i = 1 to nLen
		cItem = aList[i]
		
		if isString(cItem)
			cJSON += '"' + cItem + '"'
		but isNumber(cItem)
			cJSON += "" + cItem
		but isList(cItem)
			cJSON += _listToJSON(cItem)
		ok
		
		if i < nLen
			cJSON += ","
		ok
	next
	
	cJSON += "]"
	return cJSON

def ToCSV()
	cCSV = "Metric,Value" + nl
	
	cCSV += "Start Date," + @cStartDate + nl
	cCSV += "End Date," + @cEndDate + nl
	cCSV += "Year," + @nYear + nl
	cCSV += "Month," + @nMonth + nl
	cCSV += "Quarter," + @cQuarter + nl
	cCSV += "Total Days," + This.TotalDays() + nl
	cCSV += "Working Days," + This.AvailableDays() + nl
	cCSV += "Available Hours," + This.AvailableHours() + nl
	cCSV += "Business Start," + @cBusinessStart + nl
	cCSV += "Business End," + @cBusinessEnd + nl
	
	nLen = len(@aHolidays)
	for i = 1 to nLen
		cCSV += "Holiday," + @aHolidays[i][1] + "," + @aHolidays[i][2] + nl
	next
	
	nLen = len(@aBreaks)
	for i = 1 to nLen
		cCSV += "Break," + @aBreaks[i][1] + "," + @aBreaks[i][2] + "," + @aBreaks[i][3] + nl
	next
	
	return cCSV

	  #-----------------------------------------#
	 #  Visual Display System for stzCalendar  #
	#-----------------------------------------#

	# Configuration

	def SetVizWidth(n)
		@nVizWidth = max([@nVizMinWidth, n])
		
	def SetVizHeight(n)
		@nVizHeight = max([@nVizHeight, n])
		
	def VizWidth()
		return @nVizWidth
		
	def VizHeight()
		return @nVizHeight


	# Main Display Methods (matching stzTimeLine pattern)

	def ShowXT(paOptions)
		? This.ToStringXT(paOptions)

	def Show()
		? This.ToString()
		
	def ToString()
		return This.ToStringXT([])
		
	def ShowShort()
		? This.ToStringShort()

	def ToStringShort()
		return This._drawMonthGrid()

	def ToStringXT(paParams)
		bShowTable = TRUE
		
		if isList(paParams)
			nLen = len(paParams)
			for i = 1 to nLen
				if isList(paParams[i]) and len(paParams[i]) = 2
					if paParams[i][1] = :ShowTable
						bShowTable = paParams[i][2]
					ok
				ok
			next
		ok
		
		cResult = This._drawMonthGrid()
		
		if bShowTable
			cResult += nl + nl + This._buildCalendarTable()
		ok
		
		return cResult

	# Display Methods

def _drawMonthGrid()
	cResult = ""
	
	if @nMonth = 0
		return This._drawCompactYear()
	ok
	
	cMonthName = This.MonthName()
	cResult += RepeatChar(" ", 16) + cMonthName + " " + @nYear + nl
	
	aParts = stzStringQ(This.Start()).Split("-")
	cYear = aParts[1]
	cMonth = aParts[2]
	
	cFirstDay = This.Start()
	oFirstDay = new stzDate(cFirstDay)
	nFirstDayOfWeek = oFirstDay.DayOfWeek()
	nDaysInMonth = This.TotalDays()
	
	aTableData = [["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]]
	
	nDay = 1
	while nDay <= nDaysInMonth
		aWeek = []
		
		nStartCol = 1
		if nDay = 1
			nStartCol = nFirstDayOfWeek
		ok
		
		for i = 1 to nStartCol - 1
			aWeek + " "
		next
		
		nCol = nStartCol
		while nCol <= 7 and nDay <= nDaysInMonth
			cDate = cYear + "-" + cMonth + "-" + PadLeftXT('' + nDay, 2, "0")
			cCell = ""
			cEventSymbol = ""
			
			# Check for timeline events
			if @oTimeline != NULL
				cEventSymbol = _getTimelineSymbol(cDate)
			ok
			
			if This.IsHoliday(cDate)
				cCell = "[" + PadLeftXT('' + nDay, 1, " ") + "]"
			but This.IsWorkingDay(cDate) = FALSE
				cCell = RepeatChar(@cVizWeekendChar, 2)
			else
				cCell = PadLeftXT('' + nDay, 2, " ")
			ok
			
			if cEventSymbol != ""
				cCell = cEventSymbol + cCell
			ok
			
			aWeek + cCell
			nCol++
			nDay++
		end
		
		while len(aWeek) < 7
			aWeek + " "
		end
		
		aTableData + aWeek
	end
	
	oTable = new stzTable(aTableData)
	cResult += oTable.ToString()
	#TODO // Review this solution by adding a configurable ShowXT()
	# in stzTable (exmple :InterLines = FALSE), because if the
	# defautl chars used in displaying a stzTable change (become
	# different from those we use here in this hack), the the result
	# will be erronous

	cResult = substr(cResult, " │ ", "   ")
	cResult = substr(cResult, "┬", "─")
	cResult = substr(cResult, "┼", "─")
	cResult = substr(cResult, "┴", "─")

	# Drawing the legend
	cResult += NL + NL + _drawLegend()
	return cResult

def _drawLegend()
	cResult = "Legend:" + NL

	aLegend = This.Legend()
	nLen = len(aLegend)

	for i = 1 to nLen
		cResult += ("  " + aLegend[i][2] + " = " + Capitalise(aLegend[i][1]) )
		if i < nLen
			cResult += NL
		ok
	next

	return cResult

def Legend()
	aResult = []

	if This.ContainsHolidays()
		aResult + [ "holiday",  @cVizHolidayChar ]
	ok

	if This.ContainsWeekends()
		aResult + [ "weekend", @cVizWeekendChar ]
	ok

	if NOT (isString(@oTimeline) and @oTimeLine = "")

		if This.ContainsTimeLinePoints()
			aResult + [ "timeline-point", @cVizTimeLineEventChar ]
		ok

		if This.ContainsTimeLineSpans()
			aResult + [ "timeline-span", @cVizTimeLineSpanChar ]
		ok
	ok

	return aResult

	def LegendQ()
		return new stzList(This.Legend())

def _getTimelineSymbol(cDate)
	if @oTimeline = NULL
		return
	ok

	aPoints = @oTimeline.Points()
	aSpans = @oTimeline.Spans()
	
	# Check points
	nLen = len(aPoints)
	for i = 1 to nLen
		aParts = stzStringQ(aPoints[i][2]).Split(" ")
		cPointDate = aParts[1]
		if cPointDate = cDate
			return @cVizTimeLineEventChar
		ok
	next
	
	# Check spans
	_oDate_ = new stzDate(cDate)
	nLen = len(aSpans)
	for i = 1 to nLen
		cStart = aSpans[i][2]
		cEnd = aSpans[i][3]
		
		aParts = @split(cStart, " ")
		cStartDate = aParts[1]
		
		aParts = @split(cEnd, " ")
		cEndDate = aParts[1]
		
		if _oDate_ >= cStartDate and _oDate_ <= cEndDate
			return @cVizTimeLineSpanChar
		ok
	next
	
	return ""
	
	def _drawCompactYear()
		cResult = ""
		
		if @nYear = 0
			return "No calendar data to display"
		ok
		
		cResult += "                    " + @nYear + " Overview" + nl
		cResult += nl
		
		aQuarters = [
			[1, 3, "Q1"],
			[4, 6, "Q2"],
			[7, 9, "Q3"],
			[10, 12, "Q4"]
		]
		
		nLen = len(aQuarters)
		for i = 1 to nLen
			nStartMonth = aQuarters[i][1]
			nEndMonth = aQuarters[i][2]
			cQuarter = aQuarters[i][3]
			
			cResult += cQuarter + " Months: "
			
			for nMonth = nStartMonth to nEndMonth
				oCalTemp = new stzCalendar([@nYear, nMonth])
				# Transfer constraints from parent to temp
				oCalTemp.@aWorkingDays = This.@aWorkingDays
				oCalTemp.@aHolidays = This.@aHolidays
				oCalTemp.@aBreaks = This.@aBreaks
				oCalTemp.@cBusinessStart = This.@cBusinessStart
				oCalTemp.@cBusinessEnd = This.@cBusinessEnd
				
				nDays = oCalTemp.AvailableDays()
				nHours = oCalTemp.AvailableHours()
				
				cMonthName = oCalTemp.MonthName()
				cResult += cMonthName + "(" + nDays + "d/" + nHours + "h) "
			next
			
			cResult += nl
		next
		
		return cResult


	def _buildCalendarTable()
		aTableData = [
			[:METRIC, :VALUE]
		]
		
		aTableData + ["Total Days", This.TotalDays()]
		aTableData + ["Working Days", This.AvailableDaysN()]
		aTableData + ["Weekend Days", This.TotalDays() - This.AvailableDaysN() - len(@aHolidays)]
		aTableData + ["Holidays", len(@aHolidays)]
		aTableData + ["Total Available Hours", ''+ This.AvailableHoursN()]
		
		if This.AvailableDaysN() > 0
			aTableData + ["Average Hours Per Day", floor(This.AvailableHoursN() / This.AvailableDaysN())]
		ok
		
		aTableData + ["First Working Day", This.FirstWorkingDay()]
		aTableData + ["Last Working Day", This.LastWorkingDay()]
		aTableData + ["Business Hours", @cBusinessStart + " - " + @cBusinessEnd]
		
		if len(@aHolidays) > 0
			cHolidaysList = ""
			nLen = len(@aHolidays)
			for i = 1 to nLen
				if i > 1
					cHolidaysList += ", "
				ok
				cHolidaysList += @aHolidays[i][2]
			next
			aTableData + ["Holidays Listed", cHolidaysList]
		ok
		
		if len(@aBreaks) > 0
			cBreaksList = ""
			nLen = len(@aBreaks)
			for i = 1 to nLen
				if i > 1
					cBreaksList += " | "
				ok
				cBreaksList += @aBreaks[i][3] + ": " + @aBreaks[i][1] + "-" + @aBreaks[i][2]
			next
			aTableData + ["Breaks", cBreaksList]
		ok
		
		oTable = new stzTable(aTableData)
		return oTable.ToString()

	def ShowHeatMap()
		? This._drawHeatMap()

	def _drawHeatMap()
		cResult = ""
		
		if @nMonth = 0
			return "Heat map available only for monthly views"
		ok
		
		cResult += This.MonthName() + " " + @nYear + " - Capacity Heat Map" + nl
		cResult += nl
		
		# Calculate weeks
		cFirstDay = This.Start()
		oFirstDay = new stzDate(cFirstDay)
		nFirstDayOfWeek = oFirstDay.DayOfWeek()
		
		nDaysInMonth = This.TotalDays()
		nWeeks = ceil((nFirstDayOfWeek - 1 + nDaysInMonth) / 7)
		
		aParts = @split(This.Start(), "-")
		cYear = aParts[1]
		cMonth = aParts[2]
		
		nDay = 1
		for nWeek = 1 to nWeeks
			cResult += "Week " + nWeek + ":  "
			
			# Calculate available capacity for this week
			nWeekCapacity = 0
			nWeekDays = 0
			
			for i = 1 to 7
				if nDay <= nDaysInMonth
					cDate = cYear + "-" + cMonth + "-" + PadLeftXT(""+ nDay, 2, "0")
					
					if This.IsWorkingDay(cDate) and not This.IsHoliday(cDate)
						nWeekCapacity++
					ok
					nWeekDays++
					nDay++
				ok
			end
			
			# Draw heat bar
			if nWeekCapacity >= 5
				cResult += RepeatChar(@cVizBlockChar, 5) + " (5/5 days available)"
			but nWeekCapacity = 4
				cResult += RepeatChar(@cVizBlockChar, 4) + @cVizWeekendChar + " (4/5 days available)"
			but nWeekCapacity = 3
				cResult += RepeatChar(@cVizBlockChar, 3) + RepeatChar(@cVizWeekendChar, 2) + " (3/5 days available)"
			but nWeekCapacity = 2
				cResult += RepeatChar(@cVizBlockChar, 2) + RepeatChar(@cVizWeekendChar, 3) + " (2/5 days available)"
			but nWeekCapacity = 1
				cResult += @cVizBlockChar + RepeatChar(@cVizWeekendChar, 4) + " (1/5 days available)"
			else
				cResult += RepeatChar(@cVizWeekendChar, 5) + " (0/5 days - weekend/holiday)"
			ok
			
			cResult += nl
		end
		
		cResult += nl + "Legend:" + nl
		cResult += "  " + @cVizBlockChar + " = Available working day" + nl
		cResult += "  " + @cVizWeekendChar + " = Weekend or holiday" + nl
		
		return cResult
	
	
	def DetailedTable()

		nDaysInMonth = This.TotalDays()
		aParts = @split(This.Start(), "-")
		cYear = aParts[1]
		cMonth = aParts[2]
		
		aTableData = [["Date", "Day", "Business", "Breaks", "Available"]]
		
		for nDay = 1 to nDaysInMonth
			cDate = cYear + "-" + cMonth + "-" + PadLeftXT(""+ nDay, 2, "0")
			oDate = new stzDate(cDate)
			
			cDayName = oDate.DayName()
			
			cBizHours = ""
			cBreaks = ""
			cAvailable = ""
			
			if This.IsHoliday(cDate)
				cBizHours = "HOLIDAY"
				cAvailable = "0h"
			but This.IsWorkingDay(cDate) = FALSE
				cBizHours = "WEEKEND"
				cAvailable = "0h"
			else
				cBizHours = @cBusinessStart + "-" + @cBusinessEnd
				
				if len(@aBreaks) > 0
					cBreaks = @aBreaks[1][1] + "-" + @aBreaks[1][2]
				else
					cBreaks = "─"
				ok
				
				nHours = This.AvailableHoursOnN(cDate)
				cAvailable = "" + nHours + "h"
			ok
			
			aTableData + [cDate, cDayName, cBizHours, cBreaks, cAvailable]
		next

		return aTableData

		def DetailedTableQ()
			return new stzTable(This.DetailedTable())


		def ShowTable()
			? This._drawDetailedTable()
	
	def _drawDetailedTable()
		cResult = ""
		cResult += This.MonthName() + " " + @nYear + " - Detailed View" + nl
		cResult += nl
		
		oTable = new stzTable(This.DetailedTable())
		cResult += oTable.ToString()
		
		cResult += nl + nl + "Summary:" + nl
		cResult += "  Total Days: " + This.TotalDays() + nl
		cResult += "  Working Days: " + This.AvailableDaysN() + nl
		cResult += "  Available Hours: " + This.AvailableHoursN() + nl
		
		return cResult
	
	
	def Stats()
		return This._buildStatisticalTable()

	def _buildStatisticalTable()
		aTableData = [[:METRIC, :VALUE]]
		
		aTableData + ["Total Days", This.TotalDays()]
		aTableData + ["Working Days", This.AvailableDaysN()]
		aTableData + ["Weekend Days", This.TotalDays() - This.AvailableDaysN() - len(@aHolidays)]
		aTableData + ["Holidays", len(@aHolidays)]
		aTableData + ["Total Available Hours", This.AvailableHoursN()]
		
		if This.AvailableDaysN() > 0
			aTableData + ["Average Hours Per Day", floor(This.AvailableHoursN() / This.AvailableDaysN())]
		ok
		
		aTableData + ["First Working Day", This.FirstWorkingDay()]
		aTableData + ["Last Working Day", This.LastWorkingDay()]
		
		return aTableData

	#-----------------#
	# PRIVATE HELPERS #
	#-----------------#

	def _daysDifference(cDate1, cDate2)
		return StzDateQ(cDate1).DaysTo(cDate2)

	def _getNextDay(cDate)
		return StzDateQ(cDate).NextDay()

	def _getPreviousDay(cDate)
		return StzDateQ(cDate).PreviousDay()

	def _timeToMinutes(cTime)
		return StzTimeQ(cTime).Minutes()

	def _minutesToTime(nMinutes)
		nHours = floor(nMinutes / 60)
		nMins = nMinutes % 60

		return PadLeftXT(''+ nHours, 2, "0") + ":" +
		       PadLeftXT(''+ nMins, 2, "0") + ":00"

