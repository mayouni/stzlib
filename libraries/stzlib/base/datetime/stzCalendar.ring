/*
	stzCalendar - Calendar Management and Capacity Planning in Softanza
	Manages calendar periods, working days, holidays, and capacity calculations
	String-first design: methods accept/return strings, ...Q() returns objects
*/

func StzCalendarQ(p)
	return new stzCalendar(p)

func CalendarQ(p)
	return new stzCalendar(p)

func Calendar(p)
	return new stzCalendar(p)

class stzCalendar from stzObject
	@dStart = NULL      # stzDate object
	@dEnd = NULL        # stzDate object
	@nYear = 0
	@nMonth = 0
	@cQuarter = ""
	
	@aWorkingDays = []  # [1=Mon, 2=Tue, ..., 7=Sun] or ["Monday", "Tuesday", ...]
	@aHolidays = []     # [["2024-10-05", "Independence Day"], ...]
	@aBreaks = []       # [["12:00:00", "13:00:00", "Lunch"], ...]
	@cBusinessStart = "09:00:00"
	@cBusinessEnd = "17:00:00"
	@oLocale = NULL
	@aEvents = []       # Timeline events marked for visualization
	@aConstraints = []  # Custom constraint definitions

	def init(p1, p2, p3)
		# Flexible initialization patterns
		if isNumber(p1) and isString(p2)
			# Year and month/quarter
			_initializeFromYearAndPeriod(p1, p2, p3)
		but isString(p1) and isString(p2)
			# Date range
			_initializeFromDateRange(p1, p2, p3)
		but isList(p1)
			# Named parameters
			_initializeFromList(p1, p2)
		but isNumber(p1) and p2 = NULL
			# Year only
			_initializeYear(p1, p3)
		else
			StzRaise("Invalid parameters for stzCalendar initialization")
		ok

	def _initializeFromYearAndPeriod(nYear, pPeriod, pLocale)
		@nYear = nYear
		@oLocale = _setupLocale(pLocale)
		
		cPeriod = upper(trim("" + pPeriod))
		
		if cPeriod = "Q1"
			@cQuarter = "Q1"
			@dStart = new stzDate([ nYear, 1, 1 ])
			@dEnd = new stzDate([ nYear, 3, 31 ])
		but cPeriod = "Q2"
			@cQuarter = "Q2"
			@dStart = new stzDate([ nYear, 4, 1 ])
			@dEnd = new stzDate([ nYear, 6, 30 ])
		but cPeriod = "Q3"
			@cQuarter = "Q3"
			@dStart = new stzDate([ nYear, 7, 1 ])
			@dEnd = new stzDate([ nYear, 9, 30 ])
		but cPeriod = "Q4"
			@cQuarter = "Q4"
			@dStart = new stzDate([ nYear, 10, 1 ])
			@dEnd = new stzDate([ nYear, 12, 31 ])
		else
			# Try as month name
			nMonth = _monthNameToNumber(cPeriod)
			if nMonth > 0
				@nMonth = nMonth
				@dStart = new stzDate([ nYear, nMonth, 1 ])
				oStart = new stzDate([ nYear, nMonth, 1 ])
				@dEnd = oStart.DayAfterMonthEnd()
			else
				StzRaise("Invalid period: " + pPeriod)
			ok
		ok

	def _initializeYear(nYear, pLocale)
		@nYear = nYear
		@oLocale = _setupLocale(pLocale)
		@dStart = new stzDate([ nYear, 1, 1 ])
		@dEnd = new stzDate([ nYear, 12, 31 ])

	def _initializeFromDateRange(cStart, cEnd, pLocale)
		@oLocale = _setupLocale(pLocale)
		@dStart = new stzDate(cStart)
		@dEnd = new stzDate(cEnd)

	def _initializeFromList(paParams, pLocale)
		cStart = ""
		cEnd = ""
		
		if isList(paParams)
			nLen = len(paParams)
			for i = 1 to nLen
				if isList(paParams[i]) and len(paParams[i]) = 2
					if paParams[i][1] = :Start or paParams[i][1] = :From
						cStart = "" + paParams[i][2]
					but paParams[i][1] = :End or paParams[i][1] = :To
						cEnd = "" + paParams[i][2]
					but paParams[i][1] = :Year
						@nYear = paParams[i][2]
					but paParams[i][1] = :Month
						@nMonth = paParams[i][2]
					but paParams[i][1] = :Locale
						pLocale = paParams[i][2]
					ok
				ok
			next
		ok
		
		@oLocale = _setupLocale(pLocale)
		
		if cStart != "" and cEnd != ""
			@dStart = new stzDate(cStart)
			@dEnd = new stzDate(cEnd)
		ok

	def _setupLocale(pLocale)
		if pLocale = ""
			return new stzLocale("C")
		but isString(pLocale)
			return new stzLocale(pLocale)
		but isObject(pLocale)
			return pLocale
		ok
		return new stzLocale()

	def _monthNameToNumber(cName)
		aMonths = [ "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
			"JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER" ]
		nPos = find(aMonths, cName)
		return nPos

	# Boundary accessors
	def Start()
		return @dStart.ToString()
	
		def StartQ()
			return @dStart
	
	def End_()
		return @dEnd.ToString()
	
		def Endd()
			return @dEnd.ToString()

		def EndQ()
			return @dEnd
	
	def Year()
		return @nYear
	
	def MonthNumber()
		return @nMonth
	
	def MonthName()
		if @nMonth > 0
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
	
	def TotalDays()
		return @dStart.DaysUntil(@dEnd) + 1
	
	def TotalWeeks()
		return ceil(This.TotalDays() / 7.0)
	
	def Content()
		aResult = [
			:Start = This.Start(),
			:End = This.End_(),
			:Year = @nYear,
			:Month = @nMonth,
			:Quarter = @cQuarter,
			:TotalDays = This.TotalDays(),
			:WorkingDays = This.WorkingDays(),
			:Holidays = @aHolidays,
			:BusinessHours = [ :From = @cBusinessStart, :To = @cBusinessEnd ],
			:Breaks = @aBreaks
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
	
	def _dayNameToNumber(cName)
		aDays = [ "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY" ]
		nPos = find(aDays, cName)
		return nPos
	
	def _numberToDayName(nDay)
		aDays = [ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" ]
		if nDay >= 1 and nDay <= 7
			return aDays[nDay]
		ok
		return ""
	
	def IsWorkingDay(pDate)
		oDate = _toDate(pDate)
		nDayOfWeek = oDate.DayOfWeekNumber()
		if len(@aWorkingDays) = 0
			SetWorkingDays("DEFAULT")
		ok
		return find(@aWorkingDays, nDayOfWeek) > 0
	
	def FirstWorkingDay()
		oDate = new stzDate(@dStart)
		while not This.IsWorkingDay(oDate.ToString())
			oDate = oDate.NextDay()
		end
		return oDate.ToString()
	
	def LastWorkingDay()
		oDate = new stzDate(@dEnd)
		while not This.IsWorkingDay(oDate.ToString())
			oDate = oDate.PreviousDay()
		end
		return oDate.ToString()

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
			ok
			cDate = new stzDate(pHolidayOrLabel).ToString()
			@aHolidays + [cDate, pName]
		ok
	
	def IsHoliday(pDate)
		cDate = _toDate(pDate).ToString()
		nLen = len(@aHolidays)
		for i = 1 to nLen
			if @aHolidays[i][1] = cDate
				return TRUE
			ok
		next
		return FALSE
	
	def HolidayName(pDate)
		cDate = _toDate(pDate).ToString()
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
		if isList(pEnd) and StzListQ(pEnd).IsAndNamedParam()
			pEnd = pEnd[2]
		ok
		
		oStart = _toDate(pStart)
		oEnd = _toDate(pEnd)
		aResult = []
		
		nLen = len(@aHolidays)
		for i = 1 to nLen
			oHolidayDate = new stzDate(@aHolidays[i][1])
			if oHolidayDate >= oStart and oHolidayDate <= oEnd
				aResult + @aHolidays[i]
			ok
		next
		
		return aResult

	# Business hours
	def SetBusinessHours(pStart, pEnd)
		if isList(pStart)
			if isList(pStart) and len(pStart) >= 2
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
		return [ :From = @cBusinessStart, :To = @cBusinessEnd ]
	
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
			ok
			@aBreaks + ["" + pBreakStart, "" + pBreakEnd, pLabel]
		ok
	
	def Breaks()
		return @aBreaks

	# Capacity calculations
	def AvailableHours()
		return This.AvailableHoursBetween(This.Start(), This.End_())
	
	def AvailableHoursBetween(pStart, pEnd)
		oStart = _toDate(pStart)
		oEnd = _toDate(pEnd)
		nTotalHours = 0
		
		while oStart <= oEnd
			if This.IsWorkingDay(oStart.ToString()) and not This.IsHoliday(oStart.ToString())
				nDayHours = This.AvailableHoursOn(oStart.ToString())
				nTotalHours += nDayHours
			ok
			oStart = oStart.NextDay()
		end
		
		return nTotalHours
	
	def AvailableHoursOn(pDate)
		if This.IsHoliday(pDate)
			return 0
		ok
		if not This.IsWorkingDay(pDate)
			return 0
		ok
		
		oStart = new stzTime(@cBusinessStart)
		oEnd = new stzTime(@cBusinessEnd)
		nTotalMinutes = oStart.MinutesUntil(oEnd)
		
		nLen = len(@aBreaks)
		for i = 1 to nLen
			oBreakStart = new stzTime(@aBreaks[i][1])
			oBreakEnd = new stzTime(@aBreaks[i][2])
			nBreakMinutes = oBreakStart.MinutesUntil(oBreakEnd)
			nTotalMinutes -= nBreakMinutes
		next
		
		return floor(nTotalMinutes / 60.0)
	
	def AvailableDays()
		nDays = 0
		oDate = new stzDate(@dStart)
		while oDate <= @dEnd
			if This.IsWorkingDay(oDate.ToString()) and not This.IsHoliday(oDate.ToString())
				nDays++
			ok
			oDate = oDate.NextDay()
		end
		return nDays
	
	def AvailableWeeks()
		return ceil(This.AvailableDays() / 5.0)
	
	def AvailableMinutes()
		return This.AvailableHours() * 60
	
	def CanFit(pDate, pDuration)
		if isList(pDuration) and len(pDuration) >= 2
			pDuration = pDuration[2]
		ok
		
		nAvailableHours = This.AvailableHoursOn(pDate)
		nRequiredHours = val("" + pDuration)
		
		return nRequiredHours <= nAvailableHours
	
	def FirstAvailableSlot(pDuration)
		if isList(pDuration) and len(pDuration) >= 2
			pDuration = pDuration[2]
		ok
		
		nRequiredHours = val("" + pDuration)
		oDate = new stzDate(@dStart)
		
		while oDate <= @dEnd
			if This.CanFit(oDate.ToString(), :Duration = nRequiredHours)
				cStart = oDate.ToString() + " " + @cBusinessStart
				oEndTime = new stzTime(@cBusinessStart)
				oEndTime = oEndTime.AddHours(nRequiredHours)
				cEnd = oDate.ToString() + " " + oEndTime.ToString()
				return [cStart, cEnd]
			ok
			oDate = oDate.NextDay()
		end
		
		return NULL
	
	def ConsecutiveWorkingDaysAvailable(pDate)
		oDate = _toDate(pDate)
		nCount = 0
		
		while oDate <= @dEnd
			if This.IsWorkingDay(oDate.ToString()) and not This.IsHoliday(oDate.ToString())
				nCount++
			else
				exit
			ok
			oDate = oDate.NextDay()
		end
		
		return nCount

	# Navigation
	def Next_()
		This.NextMonth()
		return This
	
		def Nextt()
			return This.Next_()

	def NextMonth()
		if @nMonth > 0
			@nMonth++
			if @nMonth > 12
				@nMonth = 1
				@nYear++
			ok
			@dStart = new stzDate(@nYear, @nMonth, 1)
			oStart = new stzDate(@nYear, @nMonth, 1)
			@dEnd = oStart.DayAfterMonthEnd()
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
			@dStart = new stzDate(@nYear, @nMonth, 1)
			oStart = new stzDate(@nYear, @nMonth, 1)
			@dEnd = oStart.DayAfterMonthEnd()
		ok
	
	def NextYear()
		@nYear++
		@dStart = new stzDate(@nYear, 1, 1)
		@dEnd = new stzDate(@nYear, 12, 31)
	
	def PreviousYear()
		@nYear--
		@dStart = new stzDate(@nYear, 1, 1)
		@dEnd = new stzDate(@nYear, 12, 31)
	
	def GoTo(pDate)
		if isString(pDate) and upper(pDate) = "TODAY"
			oToday = new stzDate(date())
			@dStart = oToday
			@dEnd = oToday
		else
			oDate = _toDate(pDate)
			@dStart = oDate
			@dEnd = oDate
		ok
	
	def Current()
		if @nMonth > 0
			return This.MonthName() + " " + @nYear
		but @cQuarter != ""
			return @cQuarter + " " + @nYear
		ok
		return This.Start() + " to " + This.End_()
	
	def IsToday()
		cToday = date()
		return (@dStart.ToString() <= cToday and cToday <= @dEnd.ToString())

	# Date queries
	def WorkingDays()
		aResult = []
		oDate = new stzDate(@dStart)
		while oDate <= @dEnd
			if This.IsWorkingDay(oDate.ToString())
				aResult + oDate.ToString()
			ok
			oDate = oDate.NextDay()
		end
		return aResult
	
	def Weekends()
		aResult = []
		oDate = new stzDate(@dStart)
		while oDate <= @dEnd
			if not This.IsWorkingDay(oDate.ToString())
				aResult + oDate.ToString()
			ok
			oDate = oDate.NextDay()
		end
		return aResult
	
	def FreeDays()
		aResult = []
		oDate = new stzDate(@dStart)
		while oDate <= @dEnd
			cDateStr = oDate.ToString()
			if This.IsWorkingDay(cDateStr) and not This.IsHoliday(cDateStr) and len(@aBreaks) = 0
				aResult + cDateStr
			ok
			oDate = oDate.NextDay()
		end
		return aResult
	
	def DateInfo(pDate)
		oDate = _toDate(pDate)
		cDateStr = oDate.ToString()
		
		aResult = [
			:date = cDateStr,
			:day = _numberToDayName(oDate.DayOfWeekNumber()),
			:isWorkingDay = This.IsWorkingDay(cDateStr),
			:isHoliday = This.IsHoliday(cDateStr),
			:availableHours = This.AvailableHoursOn(cDateStr)
		]
		
		return aResult

	# Statistics
	def Stats()
		aStats = []
		
		aStats + [:totalDays, This.TotalDays()]
		aStats + [:workingDays, This.AvailableDays()]
		aStats + [:weekendDays, This.TotalDays() - This.AvailableDays() - len(@aHolidays)]
		aStats + [:holidays, len(@aHolidays)]
		aStats + [:totalAvailableHours, This.AvailableHours()]
		
		if This.AvailableDays() > 0
			aStats + [:averageHoursPerWorkingDay, floor(This.AvailableHours() / This.AvailableDays())]
		ok
		
		aStats + [:firstWorkingDay, This.FirstWorkingDay()]
		aStats + [:lastWorkingDay, This.LastWorkingDay()]
		
		return aStats

	# Copy
	def Copy()
		oCopy = new stzCalendar(This.Start(), This.End_())
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
		cResult += "─────────────────" + nl
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
	PRIVATE
	#-----------#

	def _toDate(pDate)
		if isString(pDate)
			return new stzDate(pDate)
		but isObject(pDate)
			return pDate
		ok
		return new stzDate(date())
