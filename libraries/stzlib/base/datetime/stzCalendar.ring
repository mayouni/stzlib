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

	def Content()
		aResult = [
			[:Start, This.Start()],
			[:End, This.End_()],
			[:Year, @nYear],
			[:Month, @nMonth],
			[:Quarter, @cQuarter],
			[:TotalDays, This.TotalDays()],
			[:WorkingDays, This.WorkingDays()],
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
	
	def IsWorkingDay(pDate)
		cDate = _toDateString(pDate)
		# Get day of week number (1-7, where 1=Monday, 7=Sunday)
		nDayOfWeek = _getDayOfWeek(cDate)
		
		if len(@aWorkingDays) = 0
			SetWorkingDays("DEFAULT")
		ok
		
		return find(@aWorkingDays, nDayOfWeek) > 0
	
	def _getDayOfWeek(cDate)
		return StzDateQ(cDate).DayOfWeek()
	
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
			if pName = NULL
				pName = "Holiday"
			else
				pName = "" + pName
			ok
			cDate = _toDateString(pHolidayOrLabel)
			@aHolidays + [cDate, pName]
		ok
	
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
	
	def BusinessHours()
		return [ [:From, @cBusinessStart], [:To, @cBusinessEnd] ]
	
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
	
	def Breaks()
		return @aBreaks

	# Capacity calculations
	def AvailableHours()
		return This.AvailableHoursBetween(This.Start(), This.End_())
	
def AvailableHoursBetween(pStart, pEnd)
	cStart = _toDateString(pStart)
	cEnd = _toDateString(pEnd)
	nTotalHours = 0
	nDays = StzDateQ(cStart).DaysToDate(cEnd)
	
	cDate = cStart
	for i = 0 to nDays
		if This.IsWorkingDay(cDate) and not This.IsHoliday(cDate)
			nDayHours = This.AvailableHoursOn(cDate)
			nTotalHours += nDayHours
		ok
		cDate = _getNextDay(cDate)
	next
	
	return nTotalHours
	
	def AvailableHoursOn(pDate)
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
	
	def AvailableDays()
		nDays = 0
		nTotalDays = This.TotalDays()
		cDate = @cStartDate
		
		for i = 1 to nTotalDays
			if This.IsWorkingDay(cDate) and not This.IsHoliday(cDate)
				nDays++
			ok
			cDate = _getNextDay(cDate)
		next
		
		return nDays

	
	def AvailableWeeks()
		return ceil(This.AvailableDays() / 5.0)
	
	def AvailableMinutes()
		return This.AvailableHours() * 60
	
	def CanFit(pDate, pDuration)
		nDuration = val("" + pDuration)
		nAvailableHours = This.AvailableHoursOn(pDate)
		
		return nDuration <= nAvailableHours
	
	def FirstAvailableSlot(pDuration)
		nRequiredHours = val("" + pDuration)
		cDate = @cStartDate
		
		while cDate <= @cEndDate
			if This.CanFit(cDate, nRequiredHours)
				cStart = cDate + " " + @cBusinessStart
				# Add hours to business start time
				nEndMinutes = _timeToMinutes(@cBusinessStart) + (nRequiredHours * 60)
				cEnd = cDate + " " + _minutesToTime(nEndMinutes)
				return [cStart, cEnd]
			ok
			cDate = _getNextDay(cDate)
		end
		
		return []
	
	def ConsecutiveWorkingDaysAvailable(pDate)
		cDate = _toDateString(pDate)
		nCount = 0
		
		while cDate <= @cEndDate
			if This.IsWorkingDay(cDate) and not This.IsHoliday(cDate)
				nCount++
			else
				exit
			ok
			cDate = _getNextDay(cDate)
		end
		
		return nCount

	# Navigation
	def Next_()
		This.NextMonth()
		return This
	
	def NextMonth()
		if @nMonth > 0
			@nMonth++
			if @nMonth > 12
				@nMonth = 1
				@nYear++
			ok
			_initializeMonth(@nYear, @nMonth)
		ok
	
	def Previous()
		This.PreviousMonth()
		return This
	
	def PreviousMonth()
		if @nMonth > 0
			@nMonth--
			if @nMonth < 1
				@nMonth = 12
				@nYear--
			ok
			_initializeMonth(@nYear, @nMonth)
		ok
	
	def NextYear()
		@nYear++
		@cStartDate = @nYear + "-01-01"
		@cEndDate = @nYear + "-12-31"
	
	def PreviousYear()
		@nYear--
		@cStartDate = @nYear + "-01-01"
		@cEndDate = @nYear + "-12-31"
	
	def GoTo(pDate)
		cDate = _toDateString(pDate)
		if upper(cDate) = "TODAY"
			cDate = date()
		ok
		@cStartDate = cDate
		@cEndDate = cDate
	
	def Current()
		if @nMonth > 0
			return This.MonthName() + " " + @nYear
		but @cQuarter != ""
			return @cQuarter + " " + @nYear
		ok
		return This.Start() + " to " + This.End_()
	
	def IsToday()
		cToday = date()
		return (@cStartDate <= cToday and cToday <= @cEndDate)

	# Date queries
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
	
	def FreeDays()
		aResult = []
		cDate = @cStartDate
		nDays = This.TotalDays()
		
		for i = 1 to nDays
			if This.IsWorkingDay(cDate) and
			   not This.IsHoliday(cDate) and len(@aBreaks) = 0
				aResult + cDate
			ok
			cDate = _getNextDay(cDate)
		next
		
		return aResult
	
	def DateInfo(pDate)
		cDate = _toDateString(pDate)
		
		aResult = [
			[:date, cDate],
			[:isWorkingDay, This.IsWorkingDay(cDate)],
			[:isHoliday, This.IsHoliday(cDate)],
			[:availableHours, This.AvailableHoursOn(cDate)]
		]
		
		return aResult

	# Statistics
	def Stats()
		aStats = []
		
		aStats + [[:totalDays, This.TotalDays()]]
		aStats + [[:workingDays, This.AvailableDays()]]
		aStats + [[:weekendDays, This.TotalDays() - This.AvailableDays() - len(@aHolidays)]]
		aStats + [[:holidays, len(@aHolidays)]]
		aStats + [[:totalAvailableHours, This.AvailableHours()]]
		
		if This.AvailableDays() > 0
			aStats + [[:averageHoursPerWorkingDay, floor(This.AvailableHours() / This.AvailableDays())]]
		ok
		
		aStats + [[:firstWorkingDay, This.FirstWorkingDay()]]
		aStats + [[:lastWorkingDay, This.LastWorkingDay()]]
		
		return aStats

	# Copy and Clone
	def Copy()
		oCopy = new stzCalendar(This.Start())
		oCopy.@cStartDate = This.@cStartDate
		oCopy.@cEndDate = This.@cEndDate
		oCopy.@aWorkingDays = This.@aWorkingDays
		oCopy.@aHolidays = This.@aHolidays
		oCopy.@aBreaks = This.@aBreaks
		oCopy.@cBusinessStart = This.@cBusinessStart
		oCopy.@cBusinessEnd = This.@cBusinessEnd
		oCopy.@nYear = This.@nYear
		oCopy.@nMonth = This.@nMonth
		oCopy.@cQuarter = This.@cQuarter
		return oCopy
	
	def Clone()
		return This.Copy()

	# Display
	def Show()
		? This.ToString()
	
	def ToString()
		return This.ToStringDetailed()
	
	def ToStringDetailed()
		cResult = ""
		
		cResult += This.Current() + nl + nl
		
		cResult += "Calendar Structure:" + nl
		cResult += "───────────────────" + nl
		cResult += "Start: " + This.Start() + nl
		cResult += "End: " + This.End_() + nl
		cResult += "Total Days: " + This.TotalDays() + nl
		cResult += "Working Days: " + This.AvailableDays() + nl
		cResult += "Available Hours: " + This.AvailableHours() + " hours" + nl
		cResult += nl
		
		if len(@aHolidays) > 0
			cResult += "Holidays:" + nl
			nLen = len(@aHolidays)
			for i = 1 to nLen
				cResult += "  " + @aHolidays[i][1] + " - " + @aHolidays[i][2] + nl
			next
			cResult += nl
		ok
		
		cResult += "Business Hours: " + @cBusinessStart + " to " + @cBusinessEnd + nl
		
		if len(@aBreaks) > 0
			cResult += "Breaks:" + nl
			nLen = len(@aBreaks)
			for i = 1 to nLen
				cResult += "  " + @aBreaks[i][1] + " - " + @aBreaks[i][2] + " (" + @aBreaks[i][3] + ")" + nl
			next
		ok
		
		return cResult

	#-----------#
	# PRIVATE HELPERS
	#-----------#

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

