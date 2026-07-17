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

func IsStzCalendar(p)
	if isObject(p) and classname(p) = "stzcalendar"
		return 1
	else
		return 0
	ok

	def @IsStzCalendar(p)
		return IsStzCalendar(p)

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
	@cVizBoundaryChar = char(226) + char(148) + char(130)
	@cVizSpanStartChar = "["
	@cVizSpanEndChar = "]"

	@cVizBlockChar = char(226) + char(150) + char(147)
	@cVizWeekendChar = char(226) + char(150) + char(145)
	@cVizHolidayChar = "[D]"

	@cVizTopLeftCorner = char(226) + char(149) + char(173)
	@cVizTopRightCorner = char(226) + char(149) + char(174)
	@cVizBottomLeftCorner = char(226) + char(149) + char(176)
	@cVizBottomRightCorner = char(226) + char(149) + char(175)
	@cVizTopTSeparator = char(226) + char(148) + char(156)
	@cVizBottomTSeparator = char(226) + char(148) + char(164)
	@cVizHorizontalLine = char(226) + char(148) + char(128)


	# Timeline
	@oTimeLine = NULL

	@cVizTimeLineEventChar = char(226) + char(151) + char(143)
	@cVizTimeLineSpanChar = char(226) + char(150) + char(172)

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

	def _initializeYear(_nYear_)
		@nYear = _nYear_
		@oLocale = _setupLocale("")
		@cStartDate = "" + _nYear_ + "-01-01"
		@cEndDate = "" + _nYear_ + "-12-31"

	def _initializeFromString(_cParam_)
		@oLocale = _setupLocale("")
		_cParam_ = trim(_cParam_)
		
		# Check if it's a year-quarter (e.g., "2024-Q1")
		if stzStringQ(_cParam_).Contains("-Q")
			_parseQuarterString(_cParam_)
			return
		ok
		
		# Check if it's a year-month (e.g., "2024-10")
		if stzStringQ(_cParam_).Contains("-") and len(stzStringQ(_cParam_).Split("-")) = 2
			_aParts_ = stzStringQ(_cParam_).Split("-")
			_nYear_ = val(_aParts_[1])
			_nMonth_ = val(_aParts_[2])
			if _nMonth_ >= 1 and _nMonth_ <= 12
				_initializeMonth(_nYear_, _nMonth_)
				return
			ok
		ok
		
		# Otherwise treat as a single date
		@cStartDate = _cParam_
		@cEndDate = _cParam_

	def _parseQuarterString(_cQuarter_)
		_cQuarter_ = StzUpper(trim(_cQuarter_))
		_aParts_ = stzStringQ(_cQuarter_).Split("-")
		@nYear = val(_aParts_[1])
		@cQuarter = _aParts_[2]
		
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

	def _initializeMonth(_nYear_, _nMonth_)
		@nYear = _nYear_
		@nMonth = _nMonth_
		@cStartDate =  ''+ @nYear + "-" +
			PadLeftXT(''+ _nMonth_, 2, "0") + "-01"
			
		# Calculate last day of month
		_aDaysInMonth_ = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
		
		# Check for leap year
		if (_nYear_ % 4 = 0 and _nYear_ % 100 != 0) or (_nYear_ % 400 = 0)
			_aDaysInMonth_[2] = 29
		ok
		
		_nLastDay_ = _aDaysInMonth_[_nMonth_]
		@cEndDate = ''+ @nYear + "-" +
			PadLeftXT(''+ _nMonth_, 2, "0") + "-" +
			PadLeftXT(''+ _nLastDay_, 2, "0")

	def _initializeFromList(aParams)
		@oLocale = _setupLocale("")
		_cStart_ = ""
		_cEnd_ = ""
		_nYear_ = 0
		_nMonth_ = 0
		_cQuarter_ = ""
		
		_nLen_ = len(aParams)
		
		# Check if first element is a number (year)
		if isNumber(aParams[1])
			_nYear_ = aParams[1]
			
			# Check second element
			if _nLen_ >= 2
				if isNumber(aParams[2])
					# [2024, 10] format - year and month
					_nMonth_ = aParams[2]
					_initializeMonth(_nYear_, _nMonth_)
					return
				but isString(aParams[2])
					_cValue_ = StzUpper(aParams[2])
					# Check if it's a quarter like "Q3"

					if _cValue_[1] = "Q"
						_parseQuarterString('' + _nYear_ + "-" + _cValue_)
						return
					ok
				ok
			else
				# Just year
				_initializeYear(_nYear_)
				return
			ok
		ok
		
		# Handle named parameters format: [["Start", "2024-10-01"], ["End", "2024-10-31"]]
		_i_ = 1
		while _i_ <= _nLen_
			if isList(aParams[_i_]) and len(aParams[_i_]) = 2
				_cKey_ = "" + StzLower(aParams[_i_][1])
				_cValue_ = "" + aParams[_i_][2]
				
				if _cKey_ = "start" or _cKey_ = "from"
					_cStart_ = _cValue_
				but _cKey_ = "end" or _cKey_ = "to"
					_cEnd_ = _cValue_
				but _cKey_ = "year"
					_nYear_ = val(_cValue_)
				but _cKey_ = "month"
					_nMonth_ = val(_cValue_)
				but _cKey_ = "quarter"
					_cQuarter_ = StzUpper(_cValue_)
				but _cKey_ = "lLocale"
					@oLocale = _setupLocale(_cValue_)
				ok
			ok
			_i_++
		end
		
		# Apply initialization logic based on collected params
		if _cStart_ != '' and _cEnd_ != ""
			@cStartDate = _cStart_
			@cEndDate = _cEnd_
		but _cQuarter_ != ""
			_parseQuarterString('' + _nYear_ + "-" + _cQuarter_)
		but _nYear_ > 0 and _nMonth_ > 0
			_initializeMonth(_nYear_, _nMonth_)
		but _nYear_ > 0
			_initializeYear(_nYear_)
		ok

	def _setupLocale(pLocale)
		if isString(pLocale) and pLocale != ""
			return pLocale  # For now, store as string
		ok
		return "C"

	def _monthNameToNumber(cName)
		_aMonths_ = [ "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
			"JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER" ]
		_nPos_ = find(_aMonths_, StzUpper(cName))
		return _nPos_

	def _dayNameToNumber(cName)
		_aDays_ = [ "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY" ]
		_nPos_ = find(_aDays_, StzUpper(cName))
		return _nPos_
	
	def _numberToDayName(_nDay_)
		_aDays_ = [ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" ]
		if _nDay_ >= 1 and _nDay_ <= 7
			return _aDays_[_nDay_]
		ok
		return ""

	def _dayOfYear(_nMonth_, _nDay_, _nYear_)
		_aDaysInMonth_ = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
		
		if (_nYear_ % 4 = 0 and _nYear_ % 100 != 0) or (_nYear_ % 400 = 0)
			_aDaysInMonth_[2] = 29
		ok
		
		_nTotal_ = 0
		for _i_ = 1 to _nMonth_ - 1
			_nTotal_ += _aDaysInMonth_[_i_]
		next
		
		return _nTotal_ + _nDay_

	def _countLeapYears(_nYear_)
		_nYear_--
		return floor(_nYear_ / 4) - floor(_nYear_ / 100) + floor(_nYear_ / 400)

	def _toDateString(pDate)
		if isString(pDate)
			return pDate
		ok
		return "" + pDate

	# Boundary accessors
	def Start()
		return @cStartDate
	
		def StartQ()
			return new stzDate(@cStartDate) 
	
	def End_()
		return @cEndDate
	
		def EndQ()
			return new stzDate(@cEndDate)
	
	def Year()
		return @nYear

	def MonthNumber()
		return @nMonth
	
	def MonthName()
		if @nMonth > 0 and @nMonth <= 12
			_aMonths_ = [ "January", "February", "March", "April", "May", "June",
				"July", "August", "September", "October", "November", "December" ]
			return _aMonths_[@nMonth]
		ok
		return ""
	
	def QuarterNumber()
		if @cQuarter != ""
			return val(StzRight(@cQuarter, 1))
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
		_aResult_ = [
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
		return _aResult_

	# Working days configuration
	def SetWorkingDays(pDays)
		if isString(pDays) and StzUpper(pDays) = "DEFAULT"
			@aWorkingDays = [1, 2, 3, 4, 5]  # Mon-Fri
		but isList(pDays)
			@aWorkingDays = []
			_nLen_ = len(pDays)
			for _i_ = 1 to _nLen_
				_cDay_ = StzUpper("" + pDays[_i_])
				_nDayNum_ = _dayNameToNumber(_cDay_)
				if _nDayNum_ > 0
					@aWorkingDays + _nDayNum_
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
		_cDate_ = _toDateString(pDate)
		# Get day of week number (1-7, where 1=Monday, 7=Sunday)
		_nDayOfWeek_ = _getDayOfWeek(_cDate_)
		
		if len(@aWorkingDays) = 0
			SetWorkingDays("DEFAULT")
		ok
		
		return find(@aWorkingDays, _nDayOfWeek_) > 0
	
	def _getDayOfWeek(_cDate_)
		return StzDateQ(_cDate_).DayOfWeekN()

	def FirstWorkingDay()
		_cDate_ = @cStartDate
		while not This.IsWorkingDay(_cDate_)
			_cDate_ = _getNextDay(_cDate_)
		end
		return _cDate_
	
	def LastWorkingDay()
		_cDate_ = @cEndDate
		while not This.IsWorkingDay(_cDate_)
			_cDate_ = _getPreviousDay(_cDate_)
		end
		return _cDate_

	def  WorkingDaysBetween(pStart, pEnd)
		_cStart_ = _toDateString(pStart)
		_cEnd_ = _toDateString(pEnd)
		_aResult_ = []
		
		_nLen_ = len(@aWorkingDays)
		for _i_ = 1 to _nLen_
			_oWorkingDayDate_ = new stzDate(@aWorkingDays[_i_][1])
			if _oWorkingDayDate_ >= _cStart_ and _oWorkingDayDate_ <= _cEnd_
				_aResult_ + @aWorkingDays[_i_]
			ok
		next
		
		return _aResult_

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
			_nLen_ = len(pHolidayOrLabel)
			for _i_ = 1 to _nLen_
				if isList(pHolidayOrLabel[_i_]) and len(pHolidayOrLabel[_i_]) = 2
					@aHolidays + pHolidayOrLabel[_i_]
				ok
			next
		but isString(pHolidayOrLabel)
			if pName = ""
				pName = "Holiday"
			else
				pName = "" + pName
			ok
			_cDate_ = _toDateString(pHolidayOrLabel)
			@aHolidays + [_cDate_, pName]
		ok
	
		This.InvalidateCache()

	def ContainsHolidays()
		return len(@aHolidays) > 0

		def HasHolidays()
			return len(@aHolidays)

	def IsHoliday(pDate)
		_cDate_ = _toDateString(pDate)
		_nLen_ = len(@aHolidays)
		for _i_ = 1 to _nLen_
			if @aHolidays[_i_][1] = _cDate_
				return TRUE
			ok
		next
		return FALSE
	
	def HolidayName(pDate)
		_cDate_ = _toDateString(pDate)
		_nLen_ = len(@aHolidays)
		for _i_ = 1 to _nLen_
			if @aHolidays[_i_][1] = _cDate_
				return @aHolidays[_i_][2]
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
		_cStart_ = _toDateString(pStart)
		_cEnd_ = _toDateString(pEnd)
		_aResult_ = []
		
		_nLen_ = len(@aHolidays)
		for _i_ = 1 to _nLen_
			_oHolidayDate_ = new stzDate(@aHolidays[_i_][1])
			if _oHolidayDate_ >= _cStart_ and _oHolidayDate_ <= _cEnd_
				_aResult_ + @aHolidays[_i_]
			ok
		next
		
		return _aResult_

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
			_nLen_ = len(pBreakStart)
			for _i_ = 1 to _nLen_
				if isList(pBreakStart[_i_]) and len(pBreakStart[_i_]) >= 2
					@aBreaks + pBreakStart[_i_]
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
		_cStart_ = _toDateString(pStart)
		_cEnd_ = _toDateString(pEnd)
		_aResult_ = []
		
		_nLen_ = len(@aBreaks)
		for _i_ = 1 to _nLen_
			_oBreakDate_ = new stzDate(@aBreaks[_i_][1])
			if _oBreakDate_ >= _cStart_ and _oBreakDate_ <= _cEnd_
				_aResult_ + @a Breaks[_i_]
			ok
		next
		
		return _aResult_

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
		_cStart_ = _toDateString(pStart)
		_cEnd_ = _toDateString(pEnd)
		_nTotalHours_ = 0
		_nDays_ = StzDateQ(_cStart_).DaysToDate(_cEnd_)
		
		_cDate_ = _cStart_
		for _i_ = 0 to _nDays_
			if This.IsWorkingDay(_cDate_) and not This.IsHoliday(_cDate_)
				_nDayHours_ = This.AvailableHoursOnN(_cDate_)
				_nTotalHours_ += _nDayHours_
			ok
			_cDate_ = _getNextDay(_cDate_)
		next
		
		# Cache result
		@cCachedStart = This.Start()
		@cCachedEnd = This.End_()
		@nCachedAvailableHours = _nTotalHours_
		
		return _nTotalHours_
	
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
		_aStartParts_ = @split(@cBusinessStart, ":")
		_aEndParts_ = @split(@cBusinessEnd, ":")
		
		_nStartMinutes_ = val(_aStartParts_[1]) * 60 + val(_aStartParts_[2])
		_nEndMinutes_ = val(_aEndParts_[1]) * 60 + val(_aEndParts_[2])
		_nTotalMinutes_ = _nEndMinutes_ - _nStartMinutes_
		
		_nLen_ = len(@aBreaks)
		for _i_ = 1 to _nLen_
			_aBreakStart_ = @split(@aBreaks[_i_][1], ":")
			_aBreakEnd_ = @split(@aBreaks[_i_][2], ":")
			
			_nBreakStartMinutes_ = val(_aBreakStart_[1]) * 60 + val(_aBreakStart_[2])
			_nBreakEndMinutes_ = val(_aBreakEnd_[1]) * 60 + val(_aBreakEnd_[2])
			_nBreakMinutes_ = _nBreakEndMinutes_ - _nBreakStartMinutes_
			
			_nTotalMinutes_ -= _nBreakMinutes_
		next
		
		return floor(_nTotalMinutes_ / 60.0)
	
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
		
		_nDays_ = 0
		_nTotalDays_ = This.TotalDays()
		_cDate_ = @cStartDate
		
		for _i_ = 1 to _nTotalDays_
			if This.IsWorkingDay(_cDate_) and not This.IsHoliday(_cDate_)
				_nDays_++
			ok
			_cDate_ = _getNextDay(_cDate_)
		next
		
		# Cache result
		@nCachedAvailableDays = _nDays_
		
		return _nDays_

	def AvailableDays()

		_acResult_ = []
		
		_nTotalDays_ = This.TotalDays()
		_cDate_ = @cStartDate
		
		for _i_ = 1 to _nTotalDays_
			if This.IsWorkingDay(_cDate_) and not This.IsHoliday(_cDate_)
				_acResult_ + _cDate_
			ok
			_cDate_ = _getNextDay(_cDate_)
		next
		
		return _acResult_

	def HowManyAvailableDays()
		return This.AvailableDaysN()

	def CountAvailableDays()
		return This.AvailableDaysN()

	def ContainsAvailableDays()
		return This.AvailableDaysN() > 0

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
		_nDuration_ = val("" + pDuration)
		_nAvailableHours_ = This.AvailableHoursOnN(pDate)
		
		return _nDuration_ <= _nAvailableHours_
	
	def FirstAvailableSlot(pDuration)
		_nRequiredHours_ = val("" + pDuration)
		_nDays_ = This.TotalDays()
		_cDate_ = @cStartDate
		
		for _i_ = 1 to _nDays_
			if This.CanFit(_cDate_, _nRequiredHours_)
				_cStart_ = _cDate_ + " " + @cBusinessStart
				# Add hours to business start time
				_nEndMinutes_ = _timeToMinutes(@cBusinessStart) + (_nRequiredHours_ * 60)
				_cEnd_ = _cDate_ + " " + _minutesToTime(_nEndMinutes_)
				return [_cStart_, _cEnd_]
			ok
			_cDate_ = _getNextDay(_cDate_)
		next
		
		return []

	def ConsecutiveWorkingDaysAvailable(pDate)
		if isList(pDate) and IsStartingFromNamedParamList(pDate)
			pDate = pDate[2]
		ok

		_aResult_ = []

		_cDate_ = _toDateString(pDate)
		_nDays_ = This.TotalDays()
		_nStartDay_ = _daysDifference(@cStartDate, _cDate_)
		
		for _i_ = _nStartDay_ to _nDays_
			if This.IsWorkingDay(_cDate_) and not This.IsHoliday(_cDate_)
				_aResult_ + _cDate_
			else
				exit
			ok
			_cDate_ = _getNextDay(_cDate_)
		next
		
		return _aResult_

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
	_cStart_ = _toDateString(pStart)
	_cEnd_ = _toDateString(pEnd)
	
	_nTotalDays_ = StzDateQ(_cStart_).DaysToDate(_cEnd_) + 1
	_nWorkingDays_ = 0
	_nHolidays_ = 0
	_nWeekends_ = 0
	_nAvailableHours_ = 0
	_aOverlappingEvents_ = []
	
	_cDate_ = _cStart_
	for _i_ = 1 to _nTotalDays_
		if This.IsHoliday(_cDate_)
			_nHolidays_++
		but not This.IsWorkingDay(_cDate_)
			_nWeekends_++
		else
			_nWorkingDays_++
			_nAvailableHours_ += This.AvailableHoursOnN(_cDate_)
		ok
		_cDate_ = _getNextDay(_cDate_)
	next
	
	_aResult_ = [
		[ "startdate", _cStart_],
		[ "enddate", _cEnd_],
		[ "totaldays", _nTotalDays_],
		[ "workingdays", _nWorkingDays_],
		[ "weekenddays", _nWeekends_],
		[ "holidays", _nHolidays_],
		[ "availablehours", _nAvailableHours_],
		[ "overlappingevents", _aOverlappingEvents_]
	]
	
	return _aResult_

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

	# CurrentXT: structured form of Current() -- returns a named-param
	# hash with the year/month/day breakdown of the current view.
	def CurrentXT()
		_aRes_ = [ :year = @nYear, :month = @nMonth, :day = 0 ]
		if @nMonth > 0
			_aRes_[:day] = This.CurrentDay()
		ok
		return _aRes_

	# CurrentDay / CurrentMonth / CurrentYear: trivial accessors for
	# the live wall-clock day/month/year. Honour the freezable clock
	# (see StzFreezeClock).
	def CurrentDay()
		_aYmd_ = _TodayYMD()
		return _aYmd_[3]

	def CurrentMonth()
		_aYmd_ = _TodayYMD()
		_nMonth_ = _aYmd_[2]
		_aNames_ = $aMonthNames[1][2]   # English (default)
		if _nMonth_ >= 1 and _nMonth_ <= len(_aNames_)
			return _aNames_[_nMonth_]
		ok
		return "" + _nMonth_

		def CurrentMonthN()
			_aYmd_ = _TodayYMD()
			return _aYmd_[2]

	def CurrentYear()
		_aYmd_ = _TodayYMD()
		return _aYmd_[1]


	def IsToday()
		_cToday_ = Today()
		_oToday_ = new stzDate(_cToday_)
		_oStartDate_ = new stzDate(@cStartDate)
		return (_oStartDate_ <= _cToday_ and _oToday_ <= @cEndDate)

	# Date queries

	def FirstDayOfWeek()
		_cDate_ = @cStartDate
		_oDate_ = new stzDate(_cDate_)
		_nDayOfWeek_ = _oDate_.DayOfWeek()
		
		# Go back to Monday of this week
		_nDaysBack_ = _nDayOfWeek_ - 1
		for _i_ = 1 to _nDaysBack_
			_cDate_ = _getPreviousDay(_cDate_)
		next
		
		return _cDate_
	
	def LastDayOfWeek()
		_cDate_ = @cStartDate
		_oDate_ = new stzDate(_cDate_)
		_nDayOfWeek_ = _oDate_.DayOfWeek()
		
		# Go forward to Sunday of this week
		_nDaysForward_ = 7 - _nDayOfWeek_
		for _i_ = 1 to _nDaysForward_
			_cDate_ = _getNextDay(_cDate_)
		next
		
		return _cDate_

	def WorkingDays()
		_aResult_ = []
		_cDate_ = @cStartDate
		_nDays_ = This.TotalDays()
		
		for _i_ = 1 to _nDays_
			if This.IsWorkingDay(_cDate_)
				_aResult_ + _cDate_
			ok
			_cDate_ = _getNextDay(_cDate_)
		next
		
		return _aResult_
	
	def Weekends()
		_aResult_ = []
		_cDate_ = @cStartDate
		_nDays_ = This.TotalDays()
		
		for _i_ = 1 to _nDays_
			if not This.IsWorkingDay(_cDate_)
				_aResult_ + _cDate_
			ok
			_cDate_ = _getNextDay(_cDate_)
		next
		
		return _aResult_
	
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
		_aResult_ = []
		_cDate_ = @cStartDate
		_nDays_ = This.TotalDays()
		
		for _i_ = 1 to _nDays_
			if This.IsWorkingDay(_cDate_) and not This.IsHoliday(_cDate_)
				_aResult_ + _cDate_
			ok
			_cDate_ = _getNextDay(_cDate_)
		next
		
		return _aResult_
	
	def FreeDaysN()
		return len(This.FreeDays())

		def HowManyFreeDays()
			return len(This.FreeDays())

		def CountFreeDays()
			return len(This.FreeDays())

	def ContainsFreeDays()
		return len(This.FreeDays()) > 0

		def HasFreeDays()
			return len(This.FreeDays()) > 0


	def DateInfo(pDate)
		_cDate_ = _toDateString(pDate)
		
		_aResult_ = [
			[ "date", _cDate_],
			[ "isworkingday", This.IsWorkingDay(_cDate_)],
			[ "isholiday", This.IsHoliday(_cDate_)],
			[ "availablehours", This.AvailableHoursOnN(_cDate_)]
		]
		
		return _aResult_

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
	
	_oTimelineStart_ = new stzDateTime(oTimeLine.Start())
	_oTimelineEnd_ = new stzDatetime(oTimeLine.End_())
	
	if _oTimelineStart_ < @cStartDate or _oTimelineEnd_ > @cEndDate
		? "Warning: Timeline extends beyond calendar range"
	ok

def TimelineEventsXT()
	if NOT (isObject(oTimeLine) and ring_classname(oTimeLine) = "stztimeline")
		StzRaise("Incorrect param type! oTimeLine must be a stzTimeLine object.")
	ok
	
	_aResult_ = [[:LABEL, :COUNT, :DURATION, :CONFLICTS]]
	
	_aPoints_ = @oTimeline.Points()
	_aSpans_ = @oTimeline.Spans()
	_aBlockedSpans_ = @oTimeline.BlockedSpans()
	
	_nPointCount_ = len(_aPoints_)
	if _nPointCount_ > 0
		_aResult_ + ["Points", _nPointCount_, char(226) + char(128) + char(148), 0]
	ok
	
	_nSpanCount_ = len(_aSpans_)
	if _nSpanCount_ > 0
		_aResult_ + ["Spans", _nSpanCount_, char(226) + char(128) + char(148), 0]
	ok
	
	_nBlockedCount_ = len(_aBlockedSpans_)
	if _nBlockedCount_ > 0
		_aResult_ + ["Blocked", _nBlockedCount_, char(226) + char(128) + char(148), 0]
	ok
	
	return _aResult_

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
	
	_aPoints_ = oTimeLine.Points()
	_aSpans_ = oTimeLine.Spans()
	
	_nLen_ = len(_aPoints_)
	for _i_ = 1 to _nLen_
		_cDate_ = _aPoints_[_i_][2]
		_aParts_ = @split(_cDate_, " ")
		_cDateOnly_ = _aParts_[1]
		
		if This.IsHoliday(_cDateOnly_) or not This.IsWorkingDay(_cDateOnly_)
			return TRUE
		ok
	next
	
	_nLen_ = len(_aSpans_)
	for _i_ = 1 to _nLen_
		_cStart_ = _aSpans_[_i_][2]
		_cEnd_ = _aSpans_[_i_][3]
		
		_aParts_ = @split(_cStart_, " ")
		_cStartDate_ = _aParts_[1]
		
		_aParts_ = @split(_cEnd_, " ")
		_cEndDate_ = _aParts_[1]
		
		_nDays_ = StzDateQ(_cStartDate_).DaysToDate(_cEndDate_)
		_cDate_ = _cStartDate_
		for j = 0 to _nDays_
			if This.IsHoliday(_cDate_) or not This.IsWorkingDay(_cDate_)
				return TRUE
			ok
			_cDate_ = _getNextDay(_cDate_)
		next
	next
	
	return FALSE

def ConflictsWithSpan(cLabel, aParams)
	if NOT (isObject(oTimeLine) and ring_classname(oTimeLine) = "stztimeline")
		StzRaise("Incorrect param type! oTimeLine must be a stzTimeLine object.")
	ok
	
	_aSpans_ = @oTimeline.Spans()
	_aConflicts_ = []
	
	_nLen_ = len(_aSpans_)
	for _i_ = 1 to _nLen_
		if _aSpans_[_i_][1] = cLabel
			_cStart_ = _aSpans_[_i_][2]
			_cEnd_ = _aSpans_[_i_][3]
			
			_aParts_ = @split(_cStart_, " ")
			_cStartDate_ = _aParts_[1]
			
			_aParts_ = @split(_cEnd_, " ")
			_cEndDate_ = _aParts_[1]
			
			_nDays_ = StzDateQ(_cStartDate_).DaysToDate(_cEndDate_)
			_cDate_ = _cStartDate_
			for j = 0 to _nDays_
				if This.IsHoliday(_cDate_)
					_aConflicts_ + [_cDate_, "Holiday: " + This.HolidayName(_cDate_)]
				but not This.IsWorkingDay(_cDate_)
					_aConflicts_ + [_cDate_, "Weekend"]
				ok
				_cDate_ = _getNextDay(_cDate_)
			next
		ok
	next
	
	return _aConflicts_

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
	_cDate_ = _toDateString(pDate)
	_nAvailableHours_ = This.AvailableHoursOnN(_cDate_)
	
	_nLen_ = len(@aConstraints)
	for _i_ = 1 to _nLen_
		_cConstraintName_ = @aConstraints[_i_][1]
		_aConstraintDef_ = @aConstraints[_i_][2]
		
		# Check constraint type
		if isList(_aConstraintDef_) and len(_aConstraintDef_) >= 2
			_cType_ = _aConstraintDef_[1]
			
			if _cType_ = :Every
				# Format: [:Every, :Wednesday, :From, "14:00", :To, "16:00"]
				_cDay_ = "" + _aConstraintDef_[2]
				_oDate_ = new stzDate(_cDate_)
				
				if StzUpper(_oDate_.DayName()) = StzUpper(_cDay_)
					if len(_aConstraintDef_) >= 6
						_cFrom_ = _aConstraintDef_[4]
						_cTo_ = _aConstraintDef_[6]
						_nConstraintMinutes_ = _timeWindowMinutes(_cFrom_, _cTo_)
						_nAvailableHours_ -= floor(_nConstraintMinutes_ / 60.0)
					ok
				ok
			ok
		ok
	next
	
	return max([0, _nAvailableHours_])

def _timeWindowMinutes(_cStart_, _cEnd_)
	_aStartParts_ = @split(_cStart_, ":")
	_aEndParts_ = @split(_cEnd_, ":")
	
	_nStartMinutes_ = val(_aStartParts_[1]) * 60 + val(_aStartParts_[2])
	_nEndMinutes_ = val(_aEndParts_[1]) * 60 + val(_aEndParts_[2])
	
	return _nEndMinutes_ - _nStartMinutes_

	  #-----------------------------#
	 #  MULTI-CALENDAR COMPARISON  #
	#-----------------------------#

def CompareWith(_oOtherCal_)
	if not (isobject(_oOtherCal_) and ring_classname(_oOtherCal_) = "stzcalendar")
		StzRaise("Incorrect param type! oOtherCal must be a stzCalendar object.")
	ok
	
	_aResult_ = []
	
	_aResult_ + [ :Metric, This.Current(), _oOtherCal_.Current(), :Difference ]
	
	_nThisDays_ = This.TotalDays()
	_nOtherDays_ = _oOtherCal_.TotalDays()
	_aResult_ + ["Total Days", _nThisDays_, _nOtherDays_, _nThisDays_ - _nOtherDays_]
	
	_nThisWorking_ = This.AvailableDaysN()
	_nOtherWorking_ = _oOtherCal_.AvailableDaysN()
	_aResult_ + ["Working Days", _nThisWorking_, _nOtherWorking_, _nThisWorking_ - _nOtherWorking_]
	
	_nThisHours_ = This.AvailableHoursN()
	_nOtherHours_ = _oOtherCal_.AvailableHoursN()
	_aResult_ + ["Available Hours", _nThisHours_, _nOtherHours_, _nThisHours_ - _nOtherHours_]
	
	_nThisHolidays_ = len(@aHolidays)
	_nOtherHolidays_ = len(_oOtherCal_.Holidays())
	_aResult_ + ["Holidays", _nThisHolidays_, _nOtherHolidays_, _nThisHolidays_ - _nOtherHolidays_]
	
	_nThisWeeks_ = This.TotalWeeks()
	_nOtherWeeks_ = _oOtherCal_.TotalWeeks()
	_aResult_ + ["Total Weeks", _nThisWeeks_, _nOtherWeeks_, _nThisWeeks_ - _nOtherWeeks_]
	
	return _aResult_

	#< @FunctionFluentForm

	def CompareWithQ(_oOtherCal_)
		return new stzListQ(_oOtherCal_)

	def CompareWithQR(_oOtherCal_, pcReturnType)
		switch pcReturnType
		on :stzList
			return new stzList(This.CompareWith(_oOtherCal_))

		on :stzListOfLists
			return new stzListOfLists(This.CompareWith(_oOtherCal_))

		on :stzTable
			return new stzTable(This.CompareWith(_oOtherCal_))
 
		other
			StzRaise("Insupported return type!")
		off

	#>

	#< @FunctionAlternativeForms

	def CompareTo(_oOtherCal_)
		return This.CompareWith(_oOtherCal_)

		def CompareToQ(_oOtherCal_)
			return This.CompareWithQ(_oOtherCal_)

		def CompareToQR(_oOtherCal_, pcReturnType)
			return This.CompareWithQR(_oOtherCal_, pcReturnType)

	def Compare(_oOtherCal_)
		if isList(_oOtherCal_) and IsToOrWithNamedParamList(_oOtherCal_)
			_oOtherCal_ = _oOtherCal_[2]
		ok

		return This.CompareWith(_oOtherCal_)

		def CompareQ(_oOtherCal_)
			return This.CompareWithQ(_oOtherCal_)

		def CompareQR(_oOtherCal_, pcReturnType)
			return This.CompareWithQR(_oOtherCal_, pcReturnType)

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
		_aHash_ = [
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
		return _aHash_
	
	def ToJSON()
		_aHash_ = This.ToHash()
		_cJSON_ = "{"
		_nLen_ = len(_aHash_)
		
		for _i_ = 1 to _nLen_
			_cKey_ = "" + _aHash_[_i_][1]
			_cValue_ = _aHash_[_i_][2]
			
			_cJSON_ += nl + '"' + _cKey_ + '": '
			
			if isString(_cValue_)
				_cJSON_ += '"' + _cValue_ + '"'
			but isNumber(_cValue_)
				_cJSON_ += "" + _cValue_
			but isList(_cValue_)
				_cJSON_ += _listToJSON(_cValue_)
			else
				_cJSON_ += '""'
			ok
			
			if _i_ < _nLen_
				_cJSON_ += ","
			ok
		next
		
		_cJSON_ += nl + "}"
		return _cJSON_
	
	def _listToJSON(aList)
		_cJSON_ = "["
		_nLen_ = len(aList)
		
		for _i_ = 1 to _nLen_
			_cItem_ = aList[_i_]
			
			if isString(_cItem_)
				_cJSON_ += '"' + _cItem_ + '"'
			but isNumber(_cItem_)
				_cJSON_ += "" + _cItem_
			but isList(_cItem_)
				_cJSON_ += _listToJSON(_cItem_)
			ok
			
			if _i_ < _nLen_
				_cJSON_ += ","
			ok
		next
		
		_cJSON_ += "]"
		return _cJSON_
	
	def ToCSV()
		return This.ToCSVXT(DefaultCSVSeperator())
	
	def ToCSVXT(cSep)
	
		_cCSV_ = "Metric,Value" + nl
		
		_cCSV_ += "Start Date" + cSep + @cStartDate + nl
		_cCSV_ += "End Date" + cSep + @cEndDate + nl
		_cCSV_ += "Year" + cSep + @nYear + nl
		_cCSV_ += "Month" + cSep + @nMonth + nl
		_cCSV_ += "Quarter" + cSep + @cQuarter + nl
		_cCSV_ += "Total Days" + cSep + This.TotalDays() + nl
		_cCSV_ += "Working Days" + cSep + This.AvailableDaysN() + nl
		_cCSV_ += "Available Hours" + cSep + This.AvailableHoursN() + nl
		_cCSV_ += "Business Start" + cSep + @cBusinessStart + nl
		_cCSV_ += "Business End" + cSep + @cBusinessEnd + nl
		
		_nLen_ = len(@aHolidays)
		for _i_ = 1 to _nLen_
			_cCSV_ += "Holiday" + cSep + @aHolidays[_i_][1] + cSep + @aHolidays[_i_][2] + nl
		next
		
		_nLen_ = len(@aBreaks)
		for _i_ = 1 to _nLen_
			_cCSV_ += "Break" + cSep + @aBreaks[_i_][1] + cSep + @aBreaks[_i_][2] + cSep + @aBreaks[_i_][3] + nl
		next
		
		return _cCSV_

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
		_bShowTable_ = TRUE
		
		if isList(paParams)
			_nLen_ = len(paParams)
			for _i_ = 1 to _nLen_
				if isList(paParams[_i_]) and len(paParams[_i_]) = 2
					if paParams[_i_][1] = :ShowTable
						_bShowTable_ = paParams[_i_][2]
					ok
				ok
			next
		ok
		
		_cResult_ = This._drawMonthGrid()
		
		if _bShowTable_
			_cResult_ += nl + nl + This._buildCalendarTable()
		ok
		
		return _cResult_

	# Display Methods

	def _drawMonthGrid()
		_cResult_ = ""
		
		if @nMonth = 0
			return This._drawCompactYear()
		ok
		
		_cMonthName_ = This.MonthName()
		_cResult_ += RepeatChar(" ", 16) + _cMonthName_ + " " + @nYear + nl
		
		_aParts_ = stzStringQ(This.Start()).Split("-")
		_cYear_ = _aParts_[1]
		_cMonth_ = _aParts_[2]
		
		_cFirstDay_ = This.Start()
		_oFirstDay_ = new stzDate(_cFirstDay_)
		_nFirstDayOfWeek_ = _oFirstDay_.DayOfWeek()
		_nDaysInMonth_ = This.TotalDays()
		
		_aTableData_ = [["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]]
		
		_nDay_ = 1
		while _nDay_ <= _nDaysInMonth_
			_aWeek_ = []
			
			_nStartCol_ = 1
			if _nDay_ = 1
				_nStartCol_ = _nFirstDayOfWeek_
			ok
			
			for _i_ = 1 to _nStartCol_ - 1
				_aWeek_ + " "
			next
			
			_nCol_ = _nStartCol_
			while _nCol_ <= 7 and _nDay_ <= _nDaysInMonth_
				_cDate_ = _cYear_ + "-" + _cMonth_ + "-" + PadLeftXT('' + _nDay_, 2, "0")
				_cCell_ = ""
				_cEventSymbol_ = ""
				
				# Check for timeline events
				if @oTimeline != NULL
					_cEventSymbol_ = _getTimelineSymbol(_cDate_)
				ok
				
				if This.IsHoliday(_cDate_)
					_cCell_ = "[" + PadLeftXT('' + _nDay_, 1, " ") + "]"
				but This.IsWorkingDay(_cDate_) = FALSE
					_cCell_ = RepeatChar(@cVizWeekendChar, 2)
				else
					_cCell_ = PadLeftXT('' + _nDay_, 2, " ")
				ok
				
				if _cEventSymbol_ != ""
					_cCell_ = _cEventSymbol_ + _cCell_
				ok
				
				_aWeek_ + _cCell_
				_nCol_++
				_nDay_++
			end
			
			while len(_aWeek_) < 7
				_aWeek_ + " "
			end
			
			_aTableData_ + _aWeek_
		end
		
		_oTable_ = new stzTable(_aTableData_)
		_cResult_ += _oTable_.ToString()
		#TODO // Review this solution by adding a configurable ShowXT()
		# in stzTable (exmple :InterLines = FALSE), because if the
		# defautl chars used in displaying a stzTable change (become
		# different from those we use here in this hack), the the result
		# will be erronous
	
		_cResult_ = StzReplace(_cResult_, " " + char(226) + char(148) + char(130) + " ", "   ")
		_cResult_ = StzReplace(_cResult_, char(226) + char(148) + char(172), char(226) + char(148) + char(128))
		_cResult_ = StzReplace(_cResult_, char(226) + char(148) + char(188), char(226) + char(148) + char(128))
		_cResult_ = StzReplace(_cResult_, char(226) + char(148) + char(180), char(226) + char(148) + char(128))
	
		# Drawing the legend
		_cResult_ += NL + NL + _drawLegend()
		return _cResult_
	
	def _drawLegend()
		_cResult_ = "Legend:" + NL
	
		_aLegend_ = This.Legend()
		_nLen_ = len(_aLegend_)
	
		for _i_ = 1 to _nLen_
			_cResult_ += ("  " + _aLegend_[_i_][2] + " = " + Capitalise(_aLegend_[_i_][1]) )
			if _i_ < _nLen_
				_cResult_ += NL
			ok
		next
	
		return _cResult_
	
	def Legend()
		_aResult_ = []
	
		if This.ContainsHolidays()
			_aResult_ + [ "holiday",  @cVizHolidayChar ]
		ok
	
		if This.ContainsWeekends()
			_aResult_ + [ "weekend", @cVizWeekendChar ]
		ok
	
		if NOT (isString(@oTimeline) and @oTimeLine = "")
	
			if This.ContainsTimeLinePoints()
				_aResult_ + [ "timeline-point", @cVizTimeLineEventChar ]
			ok
	
			if This.ContainsTimeLineSpans()
				_aResult_ + [ "timeline-span", @cVizTimeLineSpanChar ]
			ok
		ok
	
		return _aResult_
	
		def LegendQ()
			return new stzList(This.Legend())
	
	def _getTimelineSymbol(_cDate_)
		if @oTimeline = NULL
			return
		ok
	
		_aPoints_ = @oTimeline.Points()
		_aSpans_ = @oTimeline.Spans()
		
		# Check points
		_nLen_ = len(_aPoints_)
		for _i_ = 1 to _nLen_
			_aParts_ = stzStringQ(_aPoints_[_i_][2]).Split(" ")
			_cPointDate_ = _aParts_[1]
			if _cPointDate_ = _cDate_
				return @cVizTimeLineEventChar
			ok
		next
		
		# Check spans
		_oDate_ = new stzDate(_cDate_)
		_nLen_ = len(_aSpans_)
		for _i_ = 1 to _nLen_
			_cStart_ = _aSpans_[_i_][2]
			_cEnd_ = _aSpans_[_i_][3]
			
			_aParts_ = @split(_cStart_, " ")
			_cStartDate_ = _aParts_[1]
			
			_aParts_ = @split(_cEnd_, " ")
			_cEndDate_ = _aParts_[1]
			
			if _oDate_ >= _cStartDate_ and _oDate_ <= _cEndDate_
				return @cVizTimeLineSpanChar
			ok
		next
		
		return ""
		
		def _drawCompactYear()
			_cResult_ = ""
			
			if @nYear = 0
				return "No calendar data to display"
			ok
			
			_cResult_ += "                    " + @nYear + " Overview" + nl
			_cResult_ += nl
			
			_aQuarters_ = [
				[1, 3, "Q1"],
				[4, 6, "Q2"],
				[7, 9, "Q3"],
				[10, 12, "Q4"]
			]
			
			_nLen_ = len(_aQuarters_)
			for _i_ = 1 to _nLen_
				_nStartMonth_ = _aQuarters_[_i_][1]
				_nEndMonth_ = _aQuarters_[_i_][2]
				_cQuarter_ = _aQuarters_[_i_][3]
				
				_cResult_ += _cQuarter_ + " Months: "
				
				for _nMonth_ = _nStartMonth_ to _nEndMonth_
					_oCalTemp_ = new stzCalendar([@nYear, _nMonth_])
					# Transfer constraints from parent to temp
					_oCalTemp_.@aWorkingDays = This.@aWorkingDays
					_oCalTemp_.@aHolidays = This.@aHolidays
					_oCalTemp_.@aBreaks = This.@aBreaks
					_oCalTemp_.@cBusinessStart = This.@cBusinessStart
					_oCalTemp_.@cBusinessEnd = This.@cBusinessEnd
					
					_nDays_ = _oCalTemp_.AvailableDays()
					_nHours_ = _oCalTemp_.AvailableHours()
					
					_cMonthName_ = _oCalTemp_.MonthName()
					_cResult_ += _cMonthName_ + "(" + _nDays_ + "d/" + _nHours_ + "h) "
				next
				
				_cResult_ += nl
			next
			
			return _cResult_


	def _buildCalendarTable()
		_aTableData_ = [
			[:METRIC, :VALUE]
		]
		
		_aTableData_ + ["Total Days", This.TotalDays()]
		_aTableData_ + ["Working Days", This.AvailableDaysN()]
		_aTableData_ + ["Weekend Days", This.TotalDays() - This.AvailableDaysN() - len(@aHolidays)]
		_aTableData_ + ["Holidays", len(@aHolidays)]
		_aTableData_ + ["Total Available Hours", ''+ This.AvailableHoursN()]
		
		if This.AvailableDaysN() > 0
			_aTableData_ + ["Average Hours Per Day", floor(This.AvailableHoursN() / This.AvailableDaysN())]
		ok
		
		_aTableData_ + ["First Working Day", This.FirstWorkingDay()]
		_aTableData_ + ["Last Working Day", This.LastWorkingDay()]
		_aTableData_ + ["Business Hours", @cBusinessStart + " - " + @cBusinessEnd]
		
		if len(@aHolidays) > 0
			_cHolidaysList_ = ""
			_nLen_ = len(@aHolidays)
			for _i_ = 1 to _nLen_
				if _i_ > 1
					_cHolidaysList_ += ", "
				ok
				_cHolidaysList_ += @aHolidays[_i_][2]
			next
			_aTableData_ + ["Holidays Listed", _cHolidaysList_]
		ok
		
		if len(@aBreaks) > 0
			_cBreaksList_ = ""
			_nLen_ = len(@aBreaks)
			for _i_ = 1 to _nLen_
				if _i_ > 1
					_cBreaksList_ += " | "
				ok
				_cBreaksList_ += @aBreaks[_i_][3] + ": " + @aBreaks[_i_][1] + "-" + @aBreaks[_i_][2]
			next
			_aTableData_ + ["Breaks", _cBreaksList_]
		ok
		
		_oTable_ = new stzTable(_aTableData_)
		return _oTable_.ToString()

	def ShowHeatMap()
		? This._drawHeatMap()

	def _drawHeatMap()
		_cResult_ = ""
		
		if @nMonth = 0
			return "Heat map available only for monthly views"
		ok
		
		_cResult_ += This.MonthName() + " " + @nYear + " - Capacity Heat Map" + nl
		_cResult_ += nl
		
		# Calculate weeks
		_cFirstDay_ = This.Start()
		_oFirstDay_ = new stzDate(_cFirstDay_)
		_nFirstDayOfWeek_ = _oFirstDay_.DayOfWeek()
		
		_nDaysInMonth_ = This.TotalDays()
		_nWeeks_ = ceil((_nFirstDayOfWeek_ - 1 + _nDaysInMonth_) / 7)
		
		_aParts_ = @split(This.Start(), "-")
		_cYear_ = _aParts_[1]
		_cMonth_ = _aParts_[2]
		
		_nDay_ = 1
		for nWeek = 1 to _nWeeks_
			_cResult_ += "Week " + nWeek + ":  "
			
			# Calculate available capacity for this week
			_nWeekCapacity_ = 0
			_nWeekDays_ = 0
			
			for _i_ = 1 to 7
				if _nDay_ <= _nDaysInMonth_
					_cDate_ = _cYear_ + "-" + _cMonth_ + "-" + PadLeftXT(""+ _nDay_, 2, "0")
					
					if This.IsWorkingDay(_cDate_) and not This.IsHoliday(_cDate_)
						_nWeekCapacity_++
					ok
					_nWeekDays_++
					_nDay_++
				ok
			end
			
			# Draw heat bar
			if _nWeekCapacity_ >= 5
				_cResult_ += RepeatChar(@cVizBlockChar, 5) + " (5/5 days available)"
			but _nWeekCapacity_ = 4
				_cResult_ += RepeatChar(@cVizBlockChar, 4) + @cVizWeekendChar + " (4/5 days available)"
			but _nWeekCapacity_ = 3
				_cResult_ += RepeatChar(@cVizBlockChar, 3) + RepeatChar(@cVizWeekendChar, 2) + " (3/5 days available)"
			but _nWeekCapacity_ = 2
				_cResult_ += RepeatChar(@cVizBlockChar, 2) + RepeatChar(@cVizWeekendChar, 3) + " (2/5 days available)"
			but _nWeekCapacity_ = 1
				_cResult_ += @cVizBlockChar + RepeatChar(@cVizWeekendChar, 4) + " (1/5 days available)"
			else
				_cResult_ += RepeatChar(@cVizWeekendChar, 5) + " (0/5 days - weekend/holiday)"
			ok
			
			_cResult_ += nl
		end
		
		_cResult_ += nl + "Legend:" + nl
		_cResult_ += "  " + @cVizBlockChar + " = Available working day" + nl
		_cResult_ += "  " + @cVizWeekendChar + " = Weekend or holiday" + nl
		
		return _cResult_
	
	
	def DetailedTable()

		_nDaysInMonth_ = This.TotalDays()
		_aParts_ = @split(This.Start(), "-")
		_cYear_ = _aParts_[1]
		_cMonth_ = _aParts_[2]
		
		_aTableData_ = [["Date", "Day", "Business", "Breaks", "Available"]]
		
		for _nDay_ = 1 to _nDaysInMonth_
			_cDate_ = _cYear_ + "-" + _cMonth_ + "-" + PadLeftXT(""+ _nDay_, 2, "0")
			_oDate_ = new stzDate(_cDate_)
			
			_cDayName_ = _oDate_.DayName()
			
			_cBizHours_ = ""
			_cBreaks_ = ""
			_cAvailable_ = ""
			
			if This.IsHoliday(_cDate_)
				_cBizHours_ = "HOLIDAY"
				_cAvailable_ = "0h"
			but This.IsWorkingDay(_cDate_) = FALSE
				_cBizHours_ = "WEEKEND"
				_cAvailable_ = "0h"
			else
				_cBizHours_ = @cBusinessStart + "-" + @cBusinessEnd
				
				if len(@aBreaks) > 0
					_cBreaks_ = @aBreaks[1][1] + "-" + @aBreaks[1][2]
				else
					_cBreaks_ = char(226) + char(148) + char(128)
				ok
				
				_nHours_ = This.AvailableHoursOnN(_cDate_)
				_cAvailable_ = "" + _nHours_ + "h"
			ok
			
			_aTableData_ + [_cDate_, _cDayName_, _cBizHours_, _cBreaks_, _cAvailable_]
		next

		return _aTableData_

		def DetailedTableQ()
			return new stzTable(This.DetailedTable())


		def ShowTable()
			? This._drawDetailedTable()
	
	def _drawDetailedTable()
		_cResult_ = ""
		_cResult_ += This.MonthName() + " " + @nYear + " - Detailed View" + nl
		_cResult_ += nl
		
		_oTable_ = new stzTable(This.DetailedTable())
		_cResult_ += _oTable_.ToString()
		
		_cResult_ += nl + nl + "Summary:" + nl
		_cResult_ += "  Total Days: " + This.TotalDays() + nl
		_cResult_ += "  Working Days: " + This.AvailableDaysN() + nl
		_cResult_ += "  Available Hours: " + This.AvailableHoursN() + nl
		
		return _cResult_
	
	
	def Stats()
		return This._buildStatisticalTable()

	def _buildStatisticalTable()
		_aTableData_ = [[:METRIC, :VALUE]]
		
		_aTableData_ + ["Total Days", This.TotalDays()]
		_aTableData_ + ["Working Days", This.AvailableDaysN()]
		_aTableData_ + ["Weekend Days", This.TotalDays() - This.AvailableDaysN() - len(@aHolidays)]
		_aTableData_ + ["Holidays", len(@aHolidays)]
		_aTableData_ + ["Total Available Hours", This.AvailableHoursN()]
		
		if This.AvailableDaysN() > 0
			_aTableData_ + ["Average Hours Per Day", floor(This.AvailableHoursN() / This.AvailableDaysN())]
		ok
		
		_aTableData_ + ["First Working Day", This.FirstWorkingDay()]
		_aTableData_ + ["Last Working Day", This.LastWorkingDay()]
		
		return _aTableData_

	#-----------------#
	# PRIVATE HELPERS #
	#-----------------#

	def _daysDifference(cDate1, cDate2)
		return StzDateQ(cDate1).DaysTo(cDate2)

	def _getNextDay(_cDate_)
		return StzDateQ(_cDate_).NextDay()

	def _getPreviousDay(_cDate_)
		return StzDateQ(_cDate_).PreviousDay()

	def _timeToMinutes(cTime)
		return StzTimeQ(cTime).Minutes()

	def _minutesToTime(nMinutes)
		_nHours_ = floor(nMinutes / 60)
		_nMins_ = nMinutes % 60

		return PadLeftXT(''+ _nHours_, 2, "0") + ":" +
		       PadLeftXT(''+ _nMins_, 2, "0") + ":00"

