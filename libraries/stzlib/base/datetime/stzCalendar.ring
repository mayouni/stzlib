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

# Holds a period of days (a year, a quarter, a month or a date range) with working days, holidays, breaks and business hours, and counts available days and hours.
#
# Build it from a year (2026), a month ([ 2026, 3 ] or the text 2026-03), a quarter (2026-Q2 or [
# 2026, "Q2" ]), a date range ([ [ "Start", "2026-03-10" ], [ "End", "2026-03-20" ] ]) or a single
# date. Set the working weekdays with SetWorkingDays (Monday to Friday is the default, set the first
# time IsWorkingDay runs), the hours with SetBusinessHours (09:00:00 to 17:00:00 by default), and
# add holidays with AddHoliday and daily breaks with AddBreak. Then ask for working days, available
# days and available hours of the whole period or of one day (AvailableHoursOnN), check that a task
# fits (CanFit, FirstAvailableSlot), attach a stzTimeLine to look for conflicts, compare two
# calendars, and export the facts with ToHash, ToJSON and ToCSV or draw them with Show, ShowHeatMap
# and ShowTable. Hours are whole hours, rounded down day by day. Month and year navigation moves the
# calendar itself. Known gaps today, each carried as a warning on its method: only the FIRST day of
# a period is checked against the holidays when days are counted (the next days are produced as
# dd/MM/yyyy text, while holidays are compared as text with the date as added); about twenty methods
# are stubs that raise Not yet implemented!, or call a method that does not exist (the Between
# families of breaks, working days and available days, GoToNext, ConflictsWithSpan,
# ContainsBreaksBetween); AvailableHoursBetweenN overwrites the whole-calendar cache;
# FirstAvailableSlot ends its slot from midnight; ContainsBusinessHours is always FALSE; going to
# the next month from December raises; a year or quarter calendar cannot be drawn.
#
#   receiver   o1 = new stzCalendar([ 2026, 3 ])
#   example    ? o1.TotalDays()
#              #--> 31
#   see        stzDate, stzTime, stzDateTime, stzTimeLine
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
	@nVizMinHeight = 3
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
	@oTimeLine = ""

	@cVizTimeLineEventChar = char(226) + char(151) + char(143)
	@cVizTimeLineSpanChar = char(226) + char(150) + char(172)

	# Cache system
	@nCachedAvailableHours = -1
	@nCachedAvailableDays = -1
	@cCachedStart = ""
	@cCachedEnd = ""


	# Builds the calendar of a year, a month, a quarter, a date range or a single date, with Monday to Friday and 09:00 to 17:00 as defaults.
	#
	#   p          what the calendar covers: a year above 1900 such as 2026, a text such as 2026-03,
	#              2026-Q2 or 2026-03-15, a list such as [ 2026, 3 ] or [ 2026, "Q3" ], or named
	#              pairs such as [ [ "Start", "2026-03-10" ], [ "End", "2026-03-20" ] ] or [ :Year =
	#              2026, :Month = 3 ]
	#   returns    nothing; the object is built
	#   note       named pairs accept Start or From, End or To, Year, Month, Quarter; the working
	#              days stay empty until SetWorkingDays or the first IsWorkingDay, which sets Monday
	#              to Friday; the locale key is never read
	#   warning    a year of 1900 or less, a number with decimals, [ ] and [ 2026, 13 ] raise;
	#              2026-q4 with a lowercase q raises R41 (only Q3 as the second list item is case-
	#              free); [ 2026, "Spring" ] silently gives the whole year; a plain list of two
	#              dates [ "2026-03-10", "2026-03-20" ] and a list holding only a Start pair leave
	#              the calendar empty; any other text, such as gregorian, becomes a one-day range
	#              whose dates cannot be read
	#   see        Copy, Start, End_
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

	# Returns the first day of the calendar as it was given or built, as a date text.
	#
	#   returns    a date text such as 2026-03-01
	#   note       StartQ answers the same day as a stzDate object
	#   see        End_, StartQ
	#@ aka  Boundary accessors
	def Start()
		return @cStartDate
	
		def StartQ()
			return new stzDate(@cStartDate) 
	
	# Returns the last day of the calendar as it was given or built, as a date text.
	#
	#   returns    a date text such as 2026-03-31
	#   note       the name carries a trailing underscore because End is a Ring keyword; EndQ
	#              answers a stzDate
	#   see        Start, EndQ
	def End_()
		return @cEndDate
	
		# Returns the last day of the calendar as a stzDate object, so date questions can be chained.
		#
		#   returns    a stzDate object
		#   note       raises when the end is not a readable date, as for a calendar built from
		#              gregorian
		#   see        End_, Start
		def EndQ()
			return new stzDate(@cEndDate)
	
	# Returns the year of a year, quarter or month calendar, and 0 for a range or a single date.
	#
	#   returns    a number such as 2026, or 0
	#   note       a calendar built from a start and an end has no year
	#   see        MonthNumber, QuarterNumber
	def Year()
		return @nYear

	# Returns the month number of a month calendar, from 1 to 12, and 0 for a year, quarter or range.
	#
	#   returns    a number from 1 to 12, or 0
	#   see        MonthName, Year
	def MonthNumber()
		return @nMonth
	
	# Returns the English name of the month of a month calendar, and an empty text for any other view.
	#
	#   returns    a month name such as March, or an empty text
	#   see        MonthNumber, Current
	def MonthName()
		if @nMonth > 0 and @nMonth <= 12
			_aMonths_ = [ "January", "February", "March", "April", "May", "June",
				"July", "August", "September", "October", "November", "December" ]
			return _aMonths_[@nMonth]
		ok
		return ""
	
	# Returns the quarter of a quarter calendar, from 1 to 4, and 0 for any other view.
	#
	#   returns    a number from 1 to 4, or 0
	#   note       only calendars built with a quarter have one
	#   see        Year, MonthNumber
	def QuarterNumber()
		if @cQuarter != ""
			return val(StzRight(@cQuarter, 1))
		ok
		return 0
	
		def QuarterN()
			return This.QuarterNumber()

	# Returns how many days the calendar spans, both end days counted.
	#
	#   returns    a number of days; 31 for March 2026
	#   note       a range whose end comes before its start gives a negative count
	#   see        TotalWeeks, AvailableDaysN
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

	# TRUE if the calendar spans at least one day.
	#
	#   returns    TRUE or FALSE
	#   note       FALSE only for a reversed range
	#   see        TotalDays, HasDays
	def ContainsDays()
		return This.TotalDays() > 0

		# TRUE if the calendar spans at least one day, as ContainsDays says.
		#
		#   returns    TRUE or FALSE
		#   see        TotalDays
		def HasDays()
			return This.TotalDays() > 0

	# Returns the number of 7-day blocks needed to cover the calendar, the day count divided by 7 and rounded up.
	#
	#   returns    a number of weeks; 5 for 31 days
	#   note       counts blocks of 7 days, not calendar weeks: 28 days is 4 and 29 days is 5
	#   see        TotalDays, AvailableWeeksN
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

	# TRUE if the calendar spans at least one 7-day block.
	#
	#   returns    TRUE or FALSE
	#   see        TotalWeeks
	def ContainsWeeks()
		return This.TotalWeeks() > 0

		# TRUE if the calendar spans at least one 7-day block, as ContainsWeeks says.
		#
		#   returns    TRUE or FALSE
		#   see        TotalWeeks
		def HasWeeks()
			return This.TotalWeeks() > 0

	# Returns the calendar's main facts, period, totals, holidays, hours and breaks, as a list of [ key, value ] pairs.
	#
	#   returns    a list of pairs; keys are lowercase text
	#   note       the keys are start, end, year, month, quarter, totaldays, workingdays, holidays,
	#              businesshours, breaks
	#   warning    the workingdays value is 0 until working days are configured, while ToHash
	#              reports the count of available days under the same idea
	#   see        ToHash, DateInfo
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

	# Sets which weekdays count as working days, from a list of day names or the word DEFAULT for Monday to Friday.
	#
	#   pDays      a list of English day names such as [ "Monday", "Wednesday" ], or the text
	#              DEFAULT
	#   returns    nothing; the object changes in place
	#   note       day names are case-free, so monday and :Monday work; an empty list leaves no
	#              working day until the next IsWorkingDay sets Monday to Friday; the cache of
	#              available hours and days is cleared
	#   warning    names that are not English day names are skipped, and numbers are ignored; a text
	#              other than DEFAULT, or a number, changes nothing
	#   see        IsWorkingDay, WorkingDaysN
	#@ aka  Working days configuration
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

	# TRUE if working days have been set, either by SetWorkingDays or by a first IsWorkingDay call.
	#
	#   returns    TRUE or FALSE
	#   note       FALSE on a new calendar: the default Monday to Friday is only set the first time
	#              IsWorkingDay is called
	#   see        SetWorkingDays, WorkingDaysN
	def ContainsWorkingDays()
		return len(@aWorkingDays) > 0

		# TRUE if working days have been set, as ContainsWorkingDays says.
		#
		#   returns    TRUE or FALSE
		#   note       FALSE on a new calendar until IsWorkingDay or SetWorkingDays runs
		#   see        SetWorkingDays
		def HasWorkingDays()
			return len(@aWorkingDays) > 0

	# Returns how many weekdays are set as working days, from 0 to 7.
	#
	#   returns    a number from 0 to 7
	#   note       0 on a new calendar until IsWorkingDay or SetWorkingDays runs; it counts weekdays
	#              of the week, not days of the calendar
	#   see        SetWorkingDays, WorkingDays
	def WorkingDaysN()
		return len(@aWorkingDays)

		# Returns how many weekdays are set as working days, from 0 to 7.
		#
		#   returns    a number from 0 to 7
		#   note       counts weekdays of the week, not days of the calendar
		#   see        WorkingDaysN
		def NumberOfWorkingDays()
			return len(@aWorkingDays)

		# Returns how many weekdays are set as working days, from 0 to 7.
		#
		#   returns    a number from 0 to 7
		#   note       counts weekdays of the week, not days of the calendar
		#   see        WorkingDaysN
		def HowManyWorkingDays()
			return len(@aWorkingDays)

		# Returns how many weekdays are set as working days, from 0 to 7.
		#
		#   returns    a number from 0 to 7
		#   note       counts weekdays of the week, not days of the calendar; WorkingDays lists the
		#              days of the calendar
		#   see        WorkingDaysN
		def CountWorkingDays()
			return len(@aWorkingDays)

	# TRUE if the weekday of the date is one of the working days, holidays not looked at.
	#
	#   pDate      the day, as a date text such as 2026-03-16 or 16/03/2026
	#   returns    TRUE or FALSE
	#   note       a holiday on a Monday is still a working day here; DateInfo tells both
	#   warning    sets Monday to Friday when no working day has been set yet; a list such as [
	#              2026, 3, 16 ] raises R21 and a text that is no date raises Cannot parse date
	#              string
	#   see        IsHoliday, SetWorkingDays
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

	# Returns the first working day of the calendar, found by stepping from the start; holidays are not skipped.
	#
	#   returns    a date text
	#   note       the answer is the start itself in its own format when that day works, otherwise a
	#              dd/MM/yyyy text
	#   see        LastWorkingDay, FirstDayOfWeek
	def FirstWorkingDay()
		_cDate_ = @cStartDate
		while not This.IsWorkingDay(_cDate_)
			_cDate_ = _getNextDay(_cDate_)
		end
		return _cDate_
	
	# Returns the last working day of the calendar, found by stepping back from the end; holidays are not skipped.
	#
	#   returns    a date text
	#   note       the answer is the end itself in its own format when that day works, otherwise a
	#              dd/MM/yyyy text
	#   see        FirstWorkingDay
	def LastWorkingDay()
		_cDate_ = @cEndDate
		while not This.IsWorkingDay(_cDate_)
			_cDate_ = _getPreviousDay(_cDate_)
		end
		return _cDate_

	# Returns the working days between two dates, meant as a list of dates.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    a list; [ ] while no working day has been set
	#   note       on a calendar with no working day set it answers [ ] without looking
	#   warning    raises R5 (Can't access the list item, Object is not list) as soon as working
	#              days are set, because it reads each weekday number as a list; WorkingDays lists
	#              the working days of the calendar itself
	#   see        WorkingDays, WorkingDaysBetweenN
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

	# Returns the number of working days between two dates, meant as a count.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    a number
	#   note       0 on a calendar with no working day set
	#   warning    raises R5 as WorkingDaysBetween does once working days are set
	#   see        WorkingDaysBetween, WorkingDaysN
	def WorkingDaysBetweenN(pStart, pEnd)
		return len(This.WorkingDaysBetween(pStart, pEnd))

		def NumberOfWorkingDaysBetween(pStart, pEnd)
			return This.WorkingDaysBetweenN(pStart, pEnd)

		def HowManyWorkingDaysBetween(pStart, pEnd)
			return This.WorkingDaysBetweenN(pStart, pEnd)

		def CountWorkingDaysBetween(pStart, pEnd)
			return This.WorkingDaysBetweenN(pStart, pEnd)

	# TRUE if any working day lies between two dates, meant as a test on the range.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    TRUE or FALSE
	#   note       FALSE on a calendar with no working day set
	#   warning    raises R5 as WorkingDaysBetween does once working days are set
	#   see        WorkingDaysBetween
	def ContainsWorkingDaysBetween(pStart, pEnd)
		return len(This.WorkingDaysBetween(pStart, pEnd)) > 0

		# Returns the number of working days between two dates, where a yes or no was meant.
		#
		#   pStart     the first day of the range, as a date text such as 2026-03-01
		#   pEnd       the last day of the range, as a date text such as 2026-03-31
		#   returns    a number, not TRUE or FALSE
		#   note       answers the count, so a nonzero number stands for yes
		#   warning    raises R5 as WorkingDaysBetween does once working days are set
		#   see        ContainsWorkingDaysBetween
		def HasWorkingDaysBetween(pStart, pEnd)
			return len(This.WorkingDaysBetween(pStart, pEnd))

	# Records a holiday date with its name, or a whole list of [ date, name ] pairs.
	#
	#   pHolidayOrLabel   a date text such as 2026-03-10, or a list of [ date, name ] pairs
	#   pName             the holiday name, or an empty text to get Holiday (ignored for a list)
	#   returns           nothing; the object changes in place
	#   note              a name that is a number is stored as text; the cache of available hours
	#                     and days is cleared
	#   warning           both arguments are required: calling with only the date raises R19; the
	#                     date is stored as written, and IsHoliday and HolidayName compare text, so
	#                     the same day in dd/MM/yyyy is not found; a number, and a list with items
	#                     that are not pairs, are skipped silently
	#   see               IsHoliday, HolidayName
	#@ aka  Holiday management
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

	# TRUE if at least one holiday has been added.
	#
	#   returns    TRUE or FALSE
	#   see        AddHoliday, HolidaysN
	def ContainsHolidays()
		return len(@aHolidays) > 0

		# Returns the number of holidays added, where a yes or no was meant.
		#
		#   returns    a number, not TRUE or FALSE
		#   note       answers the count, so 0 stands for no and a nonzero number for yes
		#   see        ContainsHolidays, HolidaysN
		def HasHolidays()
			return len(@aHolidays)

	# TRUE if the date was added as a holiday, compared as text with the stored date.
	#
	#   pDate      the day as a date text, in the same format as when added, such as 2026-03-10
	#   returns    TRUE or FALSE
	#   note       a holiday on a weekend is still a holiday
	#   warning    the same day written 10/03/2026 is not found when it was added as 2026-03-10
	#   see        HolidayName, IsWorkingDay
	def IsHoliday(pDate)
		_cDate_ = _toDateString(pDate)
		_nLen_ = len(@aHolidays)
		for _i_ = 1 to _nLen_
			if @aHolidays[_i_][1] = _cDate_
				return 1
			ok
		next
		return 0
	
	# Returns the name given to a holiday date, or an empty text when the date is no holiday.
	#
	#   pDate      the day as a date text, in the same format as when added, such as 2026-03-10
	#   returns    a name as text, or an empty text
	#   note       an unnamed holiday is named Holiday
	#   warning    text comparison: 10/03/2026 does not find a holiday added as 2026-03-10
	#   see        IsHoliday, Holidays
	def HolidayName(pDate)
		_cDate_ = _toDateString(pDate)
		_nLen_ = len(@aHolidays)
		for _i_ = 1 to _nLen_
			if @aHolidays[_i_][1] = _cDate_
				return @aHolidays[_i_][2]
			ok
		next
		return ""

	# Returns every holiday added, in order, as a list of [ date, name ] pairs.
	#
	#   returns    a list of [ date, name ] pairs
	#   note       [ ] when none was added
	#   see        HolidaysN, HolidaysBetween
	def Holidays()
		return @aHolidays
	
	# Returns how many holidays have been added.
	#
	#   returns    a number
	#   note       counts all of them, inside the calendar range or not
	#   see        Holidays, ContainsHolidays
	def HolidaysN()
		return len(@aHolidays)

		# Returns how many holidays have been added.
		#
		#   returns    a number
		#   see        HolidaysN
		def NumberOfHolidays()
			return len(@aHolidays)

		# Returns how many holidays have been added.
		#
		#   returns    a number
		#   see        HolidaysN
		def CountHolidays()
			return len(@aHolidays)

	# Returns the holidays that fall between two dates, both included, as [ date, name ] pairs.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    a list of [ date, name ] pairs
	#   note       dates are compared as dates, so dd/MM/yyyy and ISO bounds both work; an end
	#              before the start gives [ ]
	#   see        Holidays, HolidaysBetweenN
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

	# Returns how many holidays fall between two dates, both included.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    a number
	#   see        HolidaysBetween
	def HolidaysBetweenN(pStart, pEnd)
		return len(This.HolidaysBetween(pStart, pEnd))

		# Returns how many holidays fall between two dates, both included.
		#
		#   pStart     the first day of the range, as a date text such as 2026-03-01
		#   pEnd       the last day of the range, as a date text such as 2026-03-31
		#   returns    a number
		#   see        HolidaysBetweenN
		def NumberOfHolidaysBetween(pStart, pEnd)
			return len(This.HolidaysBetween(pStart, pEnd))

		# Returns how many holidays fall between two dates, both included.
		#
		#   pStart     the first day of the range, as a date text such as 2026-03-01
		#   pEnd       the last day of the range, as a date text such as 2026-03-31
		#   returns    a number
		#   see        HolidaysBetweenN
		def CountHolidaysBetween(pStart, pEnd)
			return len(This.HolidaysBetween(pStart, pEnd))

	# TRUE if at least one holiday falls between two dates, both included.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    TRUE or FALSE
	#   see        HolidaysBetween
	def ContainsHolidaysBetween(pStart, pEnd)
		return len(This.HolidaysBetween(pStart, pEnd)) > 0

		# TRUE if at least one holiday falls between two dates, as ContainsHolidaysBetween says.
		#
		#   pStart     the first day of the range, as a date text such as 2026-03-01
		#   pEnd       the last day of the range, as a date text such as 2026-03-31
		#   returns    TRUE or FALSE
		#   see        HolidaysBetween
		def HasHolidaysBetween(pStart, pEnd)
			return len(This.HolidaysBetween(pStart, pEnd)) > 0

	# Sets the daily opening and closing times that available hours are counted between.
	#
	#   pStart     the opening time as HH:mm:ss text such as 08:30:00, or a [ label, time ] pair
	#              such as the From item of BusinessHours
	#   pEnd       the closing time as HH:mm:ss text such as 17:45:00, or a [ label, time ] pair
	#   returns    nothing; the object changes in place
	#   note       the default is 09:00:00 to 17:00:00; HH:mm is read as well; the cache of
	#              available hours and days is cleared
	#   warning    the times are not checked: a text without colons breaks the hour counts later
	#   see        BusinessHours, AddBreak
	#@ aka  Business hours
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

	# Returns the opening and closing times as a list of two [ label, time ] pairs.
	#
	#   returns    a list [ [ from, 09:00:00 ], [ to, 17:00:00 ] ]
	#   note       the labels are the lowercase text from and to
	#   see        SetBusinessHours
	def BusinessHours()
		return [ [:From, @cBusinessStart], [:To, @cBusinessEnd] ]
	
	# Returns FALSE for every calendar, where a test that business hours are set was meant.
	#
	#   returns    FALSE
	#   note       business hours always exist, defaulting to 09:00:00 to 17:00:00
	#   warning    answers FALSE even after SetBusinessHours: the test reads start is not empty and
	#              end is empty
	#   see        BusinessHours, SetBusinessHours
	def ContainsBusinessHours()
		return @cBusinessStart != '' and @cBusinessEnd = ""

		# Returns FALSE for every calendar, where a test that business hours are set was meant.
		#
		#   returns    FALSE
		#   note       business hours always exist
		#   warning    answers FALSE even after SetBusinessHours, as ContainsBusinessHours does
		#   see        BusinessHours
		def HasBusinessHours()
			return @cBusinessStart != '' and @cBusinessEnd = ""

	# Records a daily break with its start, end and label, or a whole list of breaks.
	#
	#   pBreakStart   the break start as HH:mm:ss text such as 12:00:00, or a list of [ start, end,
	#                 label ] breaks
	#   pBreakEnd     the break end as HH:mm:ss text such as 13:00:00 (ignored for a list)
	#   pLabel        the break label, or an empty text to get Break (ignored for a list)
	#   returns       nothing; the object changes in place
	#   note          the break is daily and subtracted from every working day; the cache is cleared
	#   warning       all three arguments are required: calling with fewer raises R19; a list item
	#                 shorter than 2 is skipped silently
	#   see           Breaks, SetBusinessHours
	#@ aka  Breaks management
	def AddBreak(pBreakStart, pBreakEnd, pLabel)
		if isList(pBreakStart)
			_nLen_ = len(pBreakStart)
			for _i_ = 1 to _nLen_
				if isList(pBreakStart[_i_]) and len(pBreakStart[_i_]) >= 2
					@aBreaks + pBreakStart[_i_]
				ok
			next
		else
			if pLabel = ""
				pLabel = "Break"
			else
				pLabel = "" + pLabel
			ok
			@aBreaks + ["" + pBreakStart, "" + pBreakEnd, pLabel]
		ok
	
		This.InvalidateCache()

	# Returns every break added, in order, as a list of [ start, end, label ] items.
	#
	#   returns    a list of [ start, end, label ] items
	#   note       [ ] when none was added
	#   see        BreaksN, AddBreak
	def Breaks()
		return @aBreaks

	# Returns how many breaks have been added.
	#
	#   returns    a number
	#   see        Breaks
	def BreaksN()
		return len(@aBreaks)

		# Returns how many breaks have been added.
		#
		#   returns    a number
		#   see        BreaksN
		def NumberOfBreaks()
			return len(@aBreaks)

		# Returns how many breaks have been added.
		#
		#   returns    a number
		#   see        BreaksN
		def CountBreaks()
			return len(@aBreaks)

	# TRUE if at least one break has been added.
	#
	#   returns    TRUE or FALSE
	#   see        AddBreak, BreaksN
	def ContainsBreaks()
		return len(@aBreaks) > 0

		# Returns the number of breaks added, where a yes or no was meant.
		#
		#   returns    a number, not TRUE or FALSE
		#   note       answers the count, so 0 stands for no and a nonzero number for yes
		#   see        ContainsBreaks, BreaksN
		def HasBreaks()
			return len(@aBreaks)

	# Returns the breaks that fall between two dates, meant as a list.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    a list; [ ] while no break exists
	#   note       breaks are daily times, not dated, so a range makes no sense for them; Breaks
	#              lists them
	#   warning    raises R41 (Invalid numeric string) as soon as a break exists, because it reads
	#              the break time as a date; the source also holds typos (@a Breaks) that would stop
	#              it after that
	#   see        Breaks, BreaksBetweenN
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

	# Returns how many breaks fall between two dates, meant as a count.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    a number
	#   note       0 when no break exists
	#   warning    raises R41 as BreaksBetween does once a break exists
	#   see        BreaksBetween, BreaksN
	def BreaksBetweenN(pStart, pEnd)
		return len(This.BreaksBetween(pStart, pEnd))

		# Returns how many breaks fall between two dates, meant as a count.
		#
		#   pStart     the first day of the range, as a date text such as 2026-03-01
		#   pEnd       the last day of the range, as a date text such as 2026-03-31
		#   returns    a number
		#   note       0 when no break exists
		#   warning    raises R41 as BreaksBetween does once a break exists
		#   see        BreaksBetweenN
		def HowManyBreaksBetween(pStart, pEnd)
			return len(This.BreaksBetween(pStart, pEnd))

		# Returns how many breaks fall between two dates, meant as a count.
		#
		#   pStart     the first day of the range, as a date text such as 2026-03-01
		#   pEnd       the last day of the range, as a date text such as 2026-03-31
		#   returns    a number
		#   note       0 when no break exists
		#   warning    raises R41 as BreaksBetween does once a break exists
		#   see        BreaksBetweenN
		def CountBreaksBetween(pStart, pEnd)
			return len(This.BreaksBetween(pStart, pEnd))

	# TRUE if any break falls between two dates, meant as a test on the range.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    TRUE or FALSE
	#   note       the call that was meant is BreaksBetween
	#   warning    raises R14 (Calling Method without definition: reaksbetween) every time, with or
	#              without breaks, because the source calls This. reaksBetween
	#   see        BreaksBetween
	def ContainsBreaksBetween(pStart, pEnd)
		return len(This. reaksBetween(pStart, pEnd)) > 0

		# Returns the number of breaks between two dates, where a yes or no was meant.
		#
		#   pStart     the first day of the range, as a date text such as 2026-03-01
		#   pEnd       the last day of the range, as a date text such as 2026-03-31
		#   returns    a number, not TRUE or FALSE
		#   note       answers 0 when no break exists
		#   warning    raises R41 as BreaksBetween does once a break exists
		#   see        BreaksBetweenN
		def HasBreaksBetween(pStart, pEnd)
			return len(This.BreaksBetween(pStart, pEnd))

	# Raises Not yet implemented! today instead of returning the list of available hour slots of the calendar.
	#
	#   returns    nothing; always raises
	#   note       a year, quarter or range calendar printed with ToString also fails through this
	#              stub
	#   warning    the body is a stub that raises Not yet implemented!; the form that works is
	#              AvailableHoursN
	#   see        AvailableHoursN, AvailableDays
	#@ aka  Capacity calculations
	def AvailableHours()
		stzraise("Not yet implemented!")
	# Returns the total number of working hours of the calendar, summing the whole hours of every available day.
	#
	#   returns    a number of hours; 176 for March 2026 with the default hours
	#   note       each day counts the whole hours between opening and closing minus the breaks,
	#              rounded down (09:00 to 17:00 with a one hour break is 7); the answer is cached
	#              and cleared by AddHoliday, AddBreak, SetBusinessHours, SetWorkingDays and
	#              InvalidateCache
	#   warning    a holiday is subtracted only when it is the first day of the calendar: the days
	#              after it come as dd/MM/yyyy text and no longer match a holiday stored as
	#              2026-03-10; AvailableHoursBetweenN stores its sub-range answer in the same cache,
	#              so a call to it makes this method return that sub-range total until the cache is
	#              cleared
	#   see        AvailableHoursOnN, AvailableMinutesN, AvailableDaysN
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

	# TRUE if the calendar has at least one available working hour.
	#
	#   returns    TRUE or FALSE
	#   note       built on AvailableHoursN, so it shares its caveats
	#   see        AvailableHoursN
	def ContainsAvailableHours()
		return This.AvailableHoursN() > 0
	
		# TRUE if the calendar has at least one available working hour, as ContainsAvailableHours says.
		#
		#   returns    TRUE or FALSE
		#   see        AvailableHoursN
		def HasAvailableHours()
			return This.AvailableHoursN() > 0

	# Raises Not yet implemented! today instead of returning the available hour slots between two dates.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    nothing; always raises
	#   warning    the body is a stub that raises Not yet implemented!; the form that works is
	#              AvailableHoursBetweenN
	#   see        AvailableHoursBetweenN
	def AvailableHoursBetween(pStart, pEnd)
		stzraise("Not yet implemented!")
	# Returns the working hours between two dates, both included, summing the whole hours of each available day.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    a number of hours; 35 for 2026-03-09 to 2026-03-13 with one hour of break a day
	#   warning    a holiday is subtracted only on the first day of the range (the next days come as
	#              dd/MM/yyyy text); the answer is stored in the cache of the WHOLE calendar, so
	#              AvailableHoursN, AvailableMinutesN and the Contains and Has tests answer this
	#              sub-range after it until the cache is cleared
	#   see        AvailableHoursN, AvailableHoursOnN
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

	# Returns the number of breaks between two dates where the number of available hours was meant.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    a number, but of breaks
	#   note       the call that was meant is AvailableHoursBetweenN
	#   warning    the body counts BreaksBetween: 0 when no break exists and R41 as soon as one
	#              does; it never counts hours
	#   see        AvailableHoursBetweenN
	def CountAvailableHoursBetween(pStart, pEnd)
		return len(This.BreaksBetween(pStart, pEnd))

	# TRUE if the range between two dates holds at least one available working hour.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    TRUE or FALSE
	#   warning    shares the caveats of AvailableHoursBetweenN, including its cache effect on
	#              AvailableHoursN
	#   see        AvailableHoursBetweenN
	def ContainsAvailableHoursBetween(pStart, pEnd)
		return This.AvailableHoursBetweenN(pStart, pEnd) > 0
	
		# Raises Not yet implemented! today instead of telling whether the range holds available hours.
		#
		#   pStart     the first day of the range, as a date text such as 2026-03-01
		#   pEnd       the last day of the range, as a date text such as 2026-03-31
		#   returns    nothing; always raises
		#   note       ContainsAvailableHoursBetween answers the question
		#   warning    calls AvailableHoursBetween, which is a stub
		#   see        ContainsAvailableHoursBetween
		def HasAvailableHoursBetween(pStart, pEnd)
			return This.AvailableHoursBetween(pStart, pEnd) > 0

	# Raises Not yet implemented! today instead of returning the available hour slots of one day.
	#
	#   pDate      the day, as a date text such as 2026-03-10
	#   returns    nothing; always raises
	#   warning    the body is a stub that raises Not yet implemented!; the form that works is
	#              AvailableHoursOnN
	#   see        AvailableHoursOnN
	def AvailableHoursOn(pDate)
		stzraise("Not yet implemented!")
	# Returns the whole working hours of one day: 0 on a holiday or a day off, else opening to closing minus the breaks.
	#
	#   pDate      the day, as a date text such as 2026-03-10
	#   returns    a number of hours; 8 on a Monday with the default hours, 7 with a one hour break
	#   note       rounded down to whole hours: 09:00 to 17:45 is 8
	#   warning    the date must be written as the holiday was added (2026-03-10): 10/03/2026 is not
	#              found as a holiday and answers the full hours; a text that is no date raises
	#   see        AvailableHoursN, CanFit
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

	# Raises Not yet implemented! today instead of telling whether a day has available hours.
	#
	#   pDate      the day, as a date text such as 2026-03-10
	#   returns    nothing; always raises
	#   note       AvailableHoursOnN greater than 0 answers the question
	#   warning    calls AvailableHoursOn, which is a stub
	#   see        AvailableHoursOnN
	def ContainsAvailableHoursOn(pDate)
		return This.AvailableHoursOn(pDate) > 0
	
		# Raises Not yet implemented! today instead of telling whether a day has available hours.
		#
		#   pDate      the day, as a date text such as 2026-03-10
		#   returns    nothing; always raises
		#   note       AvailableHoursOnN greater than 0 answers the question
		#   warning    calls AvailableHoursOn, which is a stub
		#   see        AvailableHoursOnN
		def HasAvailableHoursOn(pDate)
			return This.AvailableHoursOn(pDate) > 0

	# Returns how many days of the calendar are working days and not holidays.
	#
	#   returns    a number of days; 22 for March 2026
	#   note       default Monday to Friday unless SetWorkingDays changed it; the answer is cached
	#   warning    a holiday is subtracted only when it is the first day of the calendar: the other
	#              days come as dd/MM/yyyy text and no longer match a holiday stored as 2026-03-10
	#   see        AvailableDays, TotalDays, WorkingDaysN
	#@ aka  Days
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

	# Returns the working days of the calendar that are not holidays, as a list of date texts.
	#
	#   returns    a list of dates
	#   note       the first date keeps the calendar's own format (2026-03-02) and every later date
	#              is dd/MM/yyyy; the list is ordered
	#   warning    a holiday is removed only when it is the first day of the calendar, for the
	#              reason given in AvailableDaysN
	#   see        AvailableDaysN, WorkingDays, FreeDays
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

	# TRUE if the calendar has at least one available day.
	#
	#   returns    TRUE or FALSE
	#   note       built on AvailableDaysN, so it shares its caveat on holidays
	#   see        AvailableDaysN
	def ContainsAvailableDays()
		return This.AvailableDaysN() > 0

		# TRUE if the calendar has at least one available day, as ContainsAvailableDays says.
		#
		#   returns    TRUE or FALSE
		#   see        AvailableDaysN
		def HasAvailableDays()
			return This.AvailableDaysN() > 0

	# Raises Not yet implemented! today instead of returning the available days between two dates.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    nothing; always raises
	#   warning    the body is a stub that raises through raise()
	#   see        AvailableDays
	def AvailableDaysBetween(pStart, pEnd) #TODO
		raise("Not yet implemented!")
	# Raises error R14 today instead of counting the available days between two dates.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    nothing; always raises
	#   warning    calls AvailabelDaysBetween, a misspelling of a method that is itself a stub
	#   see        AvailableDaysN
	#@ aka  returns a list of dates
	def AvailableDaysBetweenN(pStart, pEnd)
		return len(This.AvailabelDaysBetween(pStart, pEnd))

	def HowManyAvailableDaysBetween(pStart, pEnd)
		return This.AvailableDaysBetweenN(pStart, pEnd)

	def CountAvailableDaysBetween(pStart, pEnd)
		return this.AvailableDaysBetweenN(pStart, pEnd)

	# Raises error R14 today instead of telling whether the range holds available days.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    nothing; always raises
	#   warning    calls AvailableDaysBetweenN, which raises R14
	#   see        AvailableDaysN
	def ContainsAvailableDaysBetween(pStart, pEnd)
		return This.AvailableDaysBetweenN(pStart, pEnd) > 0

		# Raises error R14 today instead of telling whether the range holds available days.
		#
		#   pStart     the first day of the range, as a date text such as 2026-03-01
		#   pEnd       the last day of the range, as a date text such as 2026-03-31
		#   returns    nothing; always raises
		#   warning    calls AvailableDaysBetweenN, which raises R14
		#   see        AvailableDaysN
		def HasAvailableDaysBetween(pStart, pEnd)
			return This.AvailableDaysBetweenN(pStart, pEnd) > 0

	# Raises Not yet implemented! today instead of returning the available weeks as pairs of dates.
	#
	#   returns    nothing; always raises
	#   warning    the body is a stub that raises Not yet implemented!
	#   see        AvailableWeeksN
	#@ aka  --
	def AvailableWeeks()
		stzraise("Not yet implemented!")
	# Returns the number of 5-day working weeks the available days make up, rounded up.
	#
	#   returns    a number of weeks; 5 for 22 days
	#   note       the available day count divided by 5, whatever the working days set are
	#   warning    shares the caveat of AvailableDaysN on holidays
	#   see        AvailableDaysN, TotalWeeks
		#TODO// Returns a list of pairs of dates of end and start of weeks
	def AvailableWeeksN()
		return ceil(This.AvailableDaysN() / 5.0)
	
		def HowManyAvailableWeeks()
			return This.AvailableWeeksN()

		def CountAvailableWeeks()
			return This.AvailableWeeksN()

	# TRUE if the available days make up at least one working week.
	#
	#   returns    TRUE or FALSE
	#   see        AvailableWeeksN
	def ContainsAvailableWeeks()
		return This.AvailableWeeksN() > 0

		# TRUE if the available days make up at least one working week, as ContainsAvailableWeeks says.
		#
		#   returns    TRUE or FALSE
		#   see        AvailableWeeksN
		def HasAvailableWeeks()
			return This.AvailableWeeksN() > 0

	# Returns the total working minutes of the calendar, its available hours times 60.
	#
	#   returns    a number of minutes; 10560 for 176 hours
	#   note       AvailableMinutes gives the same number
	#   warning    shares the caveats of AvailableHoursN, cache included
	#   see        AvailableHoursN
	def AvailableMinutesN()
		return This.AvailableHoursN() * 60
	
		# Returns the total working minutes of the calendar as a number, its available hours times 60.
		#
		#   returns    a number of minutes, not a list
		#   note       the one available method that answers a number, on purpose
		#   warning    shares the caveats of AvailableHoursN, cache included
		#   see        AvailableMinutesN
		def AvailableMinutes()
			#NOTE// Exceptionnaly we semantically allow it to return
			# a number because it is what we really expect when
			# we ask for available minutes

			return This.AvailableHoursN() * 60

	# TRUE if the available hours of the day are at least as long as the duration.
	#
	#   pDate       the day, as a date text such as 2026-03-10
	#   pDuration   the length in hours, as a number such as 4 or a text such as 3.5
	#   returns     TRUE or FALSE
	#   note        holidays follow the date-format caveat of AvailableHoursOnN
	#   warning     compares with the whole available hours of the day, rounded down; a duration of
	#               0 fits any day, even a day off
	#   see         AvailableHoursOnN, FirstAvailableSlot
	#@ aka  -- Checking Fitness of a date-duration in the calendar
	def CanFit(pDate, pDuration)
		_nDuration_ = val("" + pDuration)
		_nAvailableHours_ = This.AvailableHoursOnN(pDate)
		
		return _nDuration_ <= _nAvailableHours_
	
	# Returns the start and end times of the first day that has room for a duration, from the start of business hours.
	#
	#   pDuration   the length in hours, as a number such as 4
	#   returns     a list [ start, end ] of date and time texts, or [ ] when no day fits
	#   note        the start is the opening time; the date part keeps the calendar's format for the
	#               first day and is dd/MM/yyyy for later days
	#   warning     the end is wrong: it counts the duration from midnight, so a 4-hour slot from
	#               09:00:00 ends at 04:00:00; holidays after the first day are not skipped; a
	#               duration above a full day gives [ ]
	#   see         CanFit, AvailableHoursOnN
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

	# Returns the run of working days that starts at the given date and stops at the first day off or holiday.
	#
	#   pDate      the first day of the run, as a date text such as 2026-03-04, or a pair [
	#              :StartingFrom, date ]
	#   returns    a list of date texts
	#   note       the given date comes back as written and the others as dd/MM/yyyy; a day off at
	#              the start gives [ ]
	#   warning    a holiday is seen only on the first day of the run (the later days come as
	#              dd/MM/yyyy text); the walk is not stopped at the end of the calendar but one day
	#              past it (from 2026-03-31 it lists 01/04/2026 too)
	#   see        ConsecutiveWorkingDaysAvailableN, WorkingDays
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

	# Returns how many working days run in a row from the given date.
	#
	#   pDate      the first day of the run, as a date text such as 2026-03-04, or a pair [
	#              :StartingFrom, date ]
	#   returns    a number of days
	#   note       0 when the first day is a day off
	#   warning    shares the caveats of ConsecutiveWorkingDaysAvailable
	#   see        ConsecutiveWorkingDaysAvailable
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

# Returns a summary of the days between two dates: totals, working days, weekend days, holidays and available hours.
#
#   pStart     the first day of the range, as a date text such as 2026-03-01
#   pEnd       the last day of the range, as a date text such as 2026-03-31
#   returns    a list of [ key, value ] pairs with the keys startdate, enddate, totaldays,
#              workingdays, weekenddays, holidays, availablehours, overlappingevents
#   note       weekenddays counts days off that are not holidays, whatever the working days set are
#   warning    a holiday is counted only on the first day of the range, as in AvailableDaysN;
#              overlappingevents is always [ ]; an end before the start gives negative totals and
#              zero counts
#   see        DateInfo, TotalDays
		#>
#@ aka  Range info
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

	# Raises Not yet implemented! today instead of answering the day after the calendar's current day.
	#
	#   returns    nothing; always raises
	#   note       stzDate has a working NextDay
	#   warning    the body is a stub that raises Not yet implemented!; the calendar keeps no
	#              current day
	#   see        GoToNextDay, Next_
	#@ aka  Navigating to next/previous Day
	def NextDay()
		stzraise("Not yet implemented!")
	# Raises Not yet implemented! today instead of moving the calendar to the next day.
	#
	#   returns    nothing; always raises
	#   note       month and year navigation work; day navigation does not
	#   warning    the body is a stub that raises Not yet implemented!
	#   see        GotoNextMonth
		#TODO// See how meonths and years are implemented
	#@ aka  NOTE// Currently the class does not save the current day in the calendar
	def GoToNextDay()
		stzraise("Not yet implemented!")
	
		def GotoNextDayQ()
			This.GotoNextDay()
			return This

	# Raises Not yet implemented! today instead of answering the day before the calendar's current day.
	#
	#   returns    nothing; always raises
	#   note       stzDate has a working PreviousDay
	#   warning    the body is a stub that raises Not yet implemented!; the calendar keeps no
	#              current day
	#   see        GoToPreviousDay, Previous
	def PreviousDay()
		stzraise("Not yet implemented!")

	# Raises Not yet implemented! today instead of moving the calendar to the previous day.
	#
	#   returns    nothing; always raises
	#   warning    the body is a stub that raises Not yet implemented!
	#   see        GoToPreviousMonth
	def GoToPreviousDay()
		stzraise("Not yet implemented!")
	
		def GotoPreviousDayQ()
			This.GotoPreviousDay()
			return THis

	# Returns the English name of the month after the calendar's month, without moving the calendar.
	#
	#   returns    a month name such as April, or nothing for a year, quarter or range view
	#   note       the trailing underscore avoids the Ring word Next; NextMonth does the same
	#   warning    raises Invalid date provided! in December, because the month number goes to 13
	#              and is not wrapped to 1
	#   see        Previous, GotoNextMonth
	#@ aka  Navigating to next/previous year
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
	
	# Moves a month calendar to the following month and rebuilds its first and last day.
	#
	#   returns    nothing; the object changes in place
	#   note       does nothing on a year, quarter or range calendar; holidays, breaks and working
	#              days are kept; GotoNextMonthQ answers the object so calls chain
	#   warning    raises R2 in December and leaves the calendar corrupted (month 13, year already
	#              moved); GoToNext, an alias meant for it, raises R14
	#   see        GoToPreviousMonth, Next_
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

		# Raises error R14 today instead of moving the calendar to the next month.
		#
		#   returns    nothing; always raises
		#   note       GotoNextMonth does the move; GotoNextQ calls it and answers the object
		#   warning    calls GoNextMonth, which exists nowhere
		#   see        GotoNextMonth
		def GoToNext()
			This.GoNextMonth()

			def GotoNextQ()
				return This.GotoNextMonthQ()


	# Returns the English name of the month before the calendar's month, without moving the calendar.
	#
	#   returns    a month name such as February, or nothing for a year, quarter or range view
	#   note       January gives December; PreviousMonth does the same
	#   see        Next_, GoToPreviousMonth
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
	
	# Moves a month calendar to the previous month and rebuilds its first and last day.
	#
	#   returns    nothing; the object changes in place
	#   note       January moves to December of the previous year; does nothing on a year, quarter
	#              or range calendar; GotoPreviousMonthQ answers the object
	#   see        GotoNextMonth, Previous
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

		# Moves a month calendar to the previous month and rebuilds its first and last day.
		#
		#   returns    nothing; the object changes in place
		#   note       the same move as GoToPreviousMonth
		#   see        GoToPreviousMonth
		def GoToPrevious()
			This.GoToPreviousMonth()

			def GoToPreviousQ()
				return This.GotoPreviousMonthQ()

	# Returns the year number after the calendar's year, without moving the calendar.
	#
	#   returns    a number such as 2027
	#   note       a range calendar has no year, so it answers 1
	#   see        PreviousYear, GoToNextYear
	#@ aka  Navigating to next/previous year
	def NextYear()
		_nYear_ = @nYear
		return _nYear_ + 1

	# Moves the calendar to the whole of the following year, from 1 January to 31 December.
	#
	#   returns    nothing; the object changes in place
	#   note       GotoNextYearQ answers the object so calls chain
	#   warning    keeps the month and quarter it had, so a March calendar becomes a year of dates
	#              still named March; a range calendar ends up in year 1 (1-01-01)
	#   see        GoToPreviousYear, NextYear
	def GoToNextYear()
		@nYear++
		@cStartDate = ''+ @nYear + "-01-01"
		@cEndDate = ''+ @nYear + "-12-31"
	
		def GotoNextYearQ()
			This.GotoNextYear()
			return This

	# Returns the year number before the calendar's year, without moving the calendar.
	#
	#   returns    a number such as 2025
	#   note       a range calendar has no year, so it answers -1
	#   see        NextYear, GoToPreviousYear
	def PreviousYear()
		_nYear_ = @nYear
		return  _nYear_ - 1

	# Moves the calendar to the whole of the previous year, from 1 January to 31 December.
	#
	#   returns    nothing; the object changes in place
	#   note       GotoPreviousYearQ answers the object so calls chain
	#   warning    keeps the month and quarter it had, as GoToNextYear does; a range calendar ends
	#              up in year -1
	#   see        GoToNextYear, PreviousYear
	def GoToPreviousYear()
		@nYear--
		@cStartDate = ''+ @nYear + "-01-01"
		@cEndDate = ''+ @nYear + "-12-31"
	
		def GotoPreviousYearQ()
			This.GotoPreviousYear()
			return THis

	# Raises Not yet implemented! today instead of moving the calendar to a given date.
	#
	#   pDate      the day to move to, as a date text such as 2026-05-01
	#   returns    nothing; always raises
	#   warning    the body is a stub that raises Not yet implemented!
	#   see        GotoNextMonth
	#@ aka  Going to a give date
	def GoTo(pDate)
		stzraise("Not yet implemented!")

	# Returns the period shown by the calendar as a short text: the month and year, the quarter and year, or the start and the end.
	#
	#   returns    a text such as March 2026, Q2 2026 or 2026-03-10 to 2026-03-20
	#   note       a whole-year calendar shows its first and last day
	#   see        CurrentDay, Start
	#@ aka  Getting info
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

	# Returns the day of the month of today, read from the clock and not from the calendar.
	#
	#   returns    a number from 1 to 31
	#   note       follows StzFreezeClock; the same whatever period the calendar covers
	#   see        CurrentMonth, CurrentYear
	#@ aka  CurrentDay / CurrentMonth / CurrentYear: trivial accessors for the live wall-clock day/month/year. Honour the freezable clock (see StzFreezeClock).
	def CurrentDay()
		_aYmd_ = _TodayYMD()
		return _aYmd_[3]

	# Returns the English name of today's month, read from the clock and not from the calendar.
	#
	#   returns    a month name such as March
	#   note       follows StzFreezeClock
	#   see        CurrentMonthN, CurrentDay
	def CurrentMonth()
		_aYmd_ = _TodayYMD()
		_nMonth_ = _aYmd_[2]
		_aNames_ = $aMonthNames[1][2]   # English (default)
		if _nMonth_ >= 1 and _nMonth_ <= len(_aNames_)
			return _aNames_[_nMonth_]
		ok
		return "" + _nMonth_

		# Returns the number of today's month, read from the clock and not from the calendar.
		#
		#   returns    a number from 1 to 12
		#   note       follows StzFreezeClock
		#   see        CurrentMonth
		def CurrentMonthN()
			_aYmd_ = _TodayYMD()
			return _aYmd_[2]

	# Returns today's year, read from the clock and not from the calendar.
	#
	#   returns    a number such as 2026
	#   note       follows StzFreezeClock
	#   see        CurrentMonth, Year
	def CurrentYear()
		_aYmd_ = _TodayYMD()
		return _aYmd_[1]


	# TRUE if today falls between the calendar's first and last day.
	#
	#   returns    TRUE or FALSE
	#   note       follows StzFreezeClock; a whole-year calendar of the current year is TRUE
	#   see        CurrentDay, Start
	def IsToday()
		_cToday_ = Today()
		_oToday_ = new stzDate(_cToday_)
		_oStartDate_ = new stzDate(@cStartDate)
		return (_oStartDate_ <= _cToday_ and _oToday_ <= @cEndDate)

	# Returns the Monday of the week that holds the calendar's first day.
	#
	#   returns    a date text
	#   note       the start itself, in its own format, when it is a Monday, otherwise dd/MM/yyyy;
	#              it can fall before the calendar starts
	#   see        LastDayOfWeek, FirstWorkingDay
	#@ aka  Date queries
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
	
	# Returns the Sunday of the week that holds the calendar's first day.
	#
	#   returns    a date text
	#   note       the start itself, in its own format, when it is a Sunday, otherwise dd/MM/yyyy;
	#              it can fall after the calendar's first week
	#   see        FirstDayOfWeek
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

	# Returns every day of the calendar that falls on a working weekday, holidays included, as a list of date texts.
	#
	#   returns    a list of dates
	#   note       the first date keeps the calendar's own format and every later date is
	#              dd/MM/yyyy; AvailableDays also drops holidays; sets Monday to Friday when none is
	#              set
	#   see        AvailableDays, Weekends
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
	
	# Returns every day of the calendar that is not a working weekday, as a list of date texts.
	#
	#   returns    a list of dates
	#   note       not only Saturday and Sunday: it follows the working days set, and a holiday on a
	#              working weekday is not listed; the first date keeps the calendar's own format
	#   see        WorkingDays, WeekendsN
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
	
	# Returns how many days of the calendar are not working weekdays.
	#
	#   returns    a number
	#   note       HowManyWeekends and CountWeekends give the same number
	#   see        Weekends, ContainsWeekends
	def WeekendsN()
		return len(This.Weekends())

		def HowManyWeekends()
			return THis.WeekendsN()

		def CountWeekends()
			return THis.WeekendsN()

	# TRUE if the calendar has at least one day that is not a working weekday.
	#
	#   returns    TRUE or FALSE
	#   see        Weekends, WeekendsN
	def ContainsWeekends()
		return len(This.Weekends()) > 0

		# Answers nothing today instead of telling whether the calendar has weekend days.
		#
		#   returns    nothing
		#   note       ContainsWeekends answers the question
		#   warning    the method has no body
		#   see        ContainsWeekends
		def HasWeekends()

	# Raises Not yet implemented! today instead of returning the weekend days between two dates.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    nothing; always raises
	#   warning    the body is a stub that raises Not yet implemented!
	#   see        Weekends
	def WeekendsBetween(pStart, pEnd)
		stzraise("Not yet implemented!")
	# Raises Not yet implemented! today instead of counting the weekend days between two dates.
	#
	#   pStart     the first day of the range, as a date text such as 2026-03-01
	#   pEnd       the last day of the range, as a date text such as 2026-03-31
	#   returns    nothing; always raises
	#   warning    calls WeekendsBetween, which is a stub
	#   see        WeekendsN
		#TODO// Returns a list days as datestrings
	def WeekendsBetweenN(pStart, pEnd)
		return len(This.WeekendsBetween(pStart, pEnd))

		def HowManyWeekendsBetween(pStart, pEnd)
			return This.WeekendsBetweenN(pStart, pEnd)

		def CountWeekendsBetween(pStart, pEnd)
			return This.WeekendsBetweenN(pStart, pEnd)


	# Returns the working days of the calendar that are not holidays, as a list of date texts.
	#
	#   returns    a list of dates
	#   note       the first date keeps the calendar's own format and every later date is dd/MM/yyyy
	#   warning    the same list as AvailableDays: breaks are not looked at although the comment
	#              promises it, and a holiday is removed only on the first day of the calendar
	#   see        AvailableDays, WorkingDays
	#@ aka  FIXED: FreeDays() - returns working days with no breaks scheduled A "free day" is a working day that's not a holiday and has no breaks
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
	
	# Returns how many working days of the calendar are not holidays.
	#
	#   returns    a number
	#   note       the same number as AvailableDaysN
	#   warning    shares the holiday caveat of FreeDays
	#   see        FreeDays, AvailableDaysN
	def FreeDaysN()
		return len(This.FreeDays())

		# Returns how many working days of the calendar are not holidays.
		#
		#   returns    a number
		#   warning    shares the holiday caveat of FreeDays
		#   see        FreeDaysN
		def HowManyFreeDays()
			return len(This.FreeDays())

		# Returns how many working days of the calendar are not holidays.
		#
		#   returns    a number
		#   warning    shares the holiday caveat of FreeDays
		#   see        FreeDaysN
		def CountFreeDays()
			return len(This.FreeDays())

	# TRUE if the calendar has at least one working day that is not a holiday.
	#
	#   returns    TRUE or FALSE
	#   warning    shares the holiday caveat of FreeDays
	#   see        FreeDays
	def ContainsFreeDays()
		return len(This.FreeDays()) > 0

		# TRUE if the calendar has at least one working day that is not a holiday, as ContainsFreeDays says.
		#
		#   returns    TRUE or FALSE
		#   see        FreeDays
		def HasFreeDays()
			return len(This.FreeDays()) > 0


	# Returns what the calendar knows about one day: the date, whether it is a working day, a holiday, and its available hours.
	#
	#   pDate      the day, as a date text such as 2026-03-10
	#   returns    a list of pairs with the keys date, isworkingday, isholiday, availablehours
	#   note       on a holiday that is a working weekday it gives isworkingday 1, isholiday 1 and
	#              availablehours 0
	#   warning    the date must be written as the holiday was added (2026-03-10): 10/03/2026
	#              reports no holiday
	#   see        IsWorkingDay, IsHoliday, AvailableHoursOnN
	def DateInfo(pDate)
		_cDate_ = _toDateString(pDate)
		
		_aResult_ = [
			[ "date", _cDate_],
			[ "isworkingday", This.IsWorkingDay(_cDate_)],
			[ "isholiday", This.IsHoliday(_cDate_)],
			[ "availablehours", This.AvailableHoursOnN(_cDate_)]
		]
		
		return _aResult_

	# Returns a new stzCalendar with the same dates, working days, holidays, breaks and business hours.
	#
	#   returns    a new stzCalendar object
	#   note       Clone is the same method; changing the copy never changes the original
	#   warning    the copy does not keep the constraints, the timeline, the viz sizes or the cache
	#   see        Clone, init
	#@ aka  Copy and Clone
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

# Attaches a stzTimeLine to the calendar so its points and spans show in the grid and can be checked for conflicts.
#
#   oTimeLine   the stzTimeLine to attach
#   returns     nothing; the object changes in place
#   note        a timeline kept strictly inside the calendar prints nothing
#   warning     raises Incorrect param type! for anything but a stzTimeLine; prints Warning:
#               Timeline extends beyond calendar range when the timeline goes past the calendar, and
#               also when it ends on the calendar's last day, because its end is read as 23:59:59
#   see         HasTimeline, ConflictsWith
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

# TRUE if a timeline has been attached with MarkTimeline.
#
#   returns    TRUE or FALSE
#   see        MarkTimeline, TimeLineObject
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

# Returns the attached timeline object, or an empty text when none was attached.
#
#   returns    a stzTimeLine object, or an empty text
#   note       TimeLineObject gives the same
#   see        HasTimeline, TimeLineEvents
def StzTimeLineObject()
	return @oTimeLine

	# Returns the attached timeline object, or an empty text when none was attached.
	#
	#   returns    a stzTimeLine object, or an empty text
	#   see        HasTimeline
	def TimeLineObject()
		return @oTimeLine

# Returns the points of the attached timeline as [ label, date and time ] pairs, or [ ] when no timeline is attached.
#
#   returns    a list of pairs; [ ] without a timeline
#   note       TimeLineMoments gives the same
#   see        TimeLineSpans, MarkTimeline
def TimeLinePoints()
	if This.HasATimeLine()
		return This.TimeLineObject().Points()
	else
		return []
	ok

	def TimeLineMoments()
		return This.TimeLinePoints()

# TRUE if the attached timeline holds at least one point.
#
#   returns    TRUE or FALSE
#   note       FALSE without a timeline
#   see        TimeLinePoints
def ContainsTimeLinePoints()
	return len(This.TimeLinePoints()) > 0

	def ContainsTimeLineMoments()
		return THis.ContainsTimeLinePoints()

	def HasTimeLinePoints()
		return THis.ContainsTimeLinePoints()

	def HasTimeLineMoments()
		return THis.ContainsTimeLinePoints()

# Returns the spans of the attached timeline as [ label, start, end ] items, or [ ] when no timeline is attached.
#
#   returns    a list of items; [ ] without a timeline
#   note       TimeLinePeriods gives the same
#   see        TimeLinePoints, MarkTimeline
def TimeLineSpans()
	if This.HasATimeLine()
		return This.TimeLineObject().Spans()
	else
		return []
	ok

	def TimeLinePeriods()
		return This.TimeLineSpans()

# TRUE if the attached timeline holds at least one span.
#
#   returns    TRUE or FALSE
#   note       FALSE without a timeline
#   see        TimeLineSpans
def ContainsTimeLineSpans()
	return len(This.TimeLineSpans()) > 0

	def ContainsTimeLinePeriods()
		return THis.ContainsTimeLineSpans()

	def HasTimeLineSpans()
		return THis.ContainsTimeLineSpans()

	def HasTimeLinePeriods()
		return THis.ContainsTimeLineSpans()





# Returns the points and the spans of the attached timeline as two pairs, or [ ] when no timeline is attached.
#
#   returns    a list [ [ points, ... ], [ spans, ... ] ], or [ ]
#   note       the pairs are keyed points and spans; an attached timeline with nothing in it still
#              gives two empty pairs
#   see        TimeLinePoints, TimeLineSpans
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

# TRUE if a timeline is attached, whether or not it holds any event.
#
#   returns    TRUE or FALSE
#   note       FALSE without a timeline
#   warning    answers TRUE for an attached timeline with no point and no span, because it counts
#              the two pairs and not the events
#   see        TimeLineEvents
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

# TRUE if a point of the timeline falls on a holiday or a day off, or a span covers one.
#
#   oTimeLine   the stzTimeLine to check
#   returns     TRUE or FALSE
#   note        the timeline does not have to be the attached one
#   warning     raises Incorrect param type! for anything but a stzTimeLine; inside a span, a
#               holiday is seen only on its first day (the later days come as dd/MM/yyyy text) while
#               day-off weekdays are seen on every day
#   see         ConflictsWithSpan, MarkTimeline
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
			return 1
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
				return 1
			ok
			_cDate_ = _getNextDay(_cDate_)
		next
	next
	
	return 0

# Raises error R24 today instead of listing the days where a named span meets a holiday or a day off.
#
#   cLabel     the span label to check
#   aParams    extra parameters, not read
#   returns    nothing; always raises
#   note       the intended answer is a list of [ date, reason ] pairs
#   warning    tests an undefined variable oTimeLine instead of the attached timeline, so it raises
#              Using uninitialized variable: otimeline for any label
#   see        ConflictsWith
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

# Stores a named constraint definition, such as a weekly window of unavailable time.
#
#   cName         the constraint name, as text
#   pConstraint   the definition as a list, such as [ :Every, :Wednesday, :From, "14:00", :To,
#                 "16:00" ]
#   returns       nothing; the object changes in place
#   note          the definition is read later by ApplyConstraints
#   warning       a name that is not text or a definition that is not a list is skipped without an
#                 error
#   see           Constraints, ApplyConstraints
def AddConstraint(cName, pConstraint)
	if isString(cName) and isList(pConstraint)
		@aConstraints + [cName, pConstraint]
	ok

# Returns every constraint stored, as a list of [ name, definition ] pairs.
#
#   returns    a list of pairs; [ ] when none was added
#   note       words inside a definition come back lowercase
#   see        AddConstraint, ApplyConstraints
def Constraints()
	return @aConstraints

# Returns the available hours of one day after taking away the windows of the matching Every constraints.
#
#   pDate      the day, as a date text such as 2026-03-11
#   returns    a number of hours, never below 0
#   note       7 hours on a Wednesday with a one hour break and a 14:00 to 16:00 window gives 5
#   warning    only definitions of the form Every, a day name, From, a start, To, an end are read,
#              any other form is ignored; each window is rounded down to whole hours; holidays
#              follow the date-format caveat of AvailableHoursOnN
#   see        AddConstraint, AvailableHoursOnN
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

# Returns a table of rows comparing this calendar with another: days, working days, hours, holidays and weeks, with the difference.
#
#   _oOtherCal_   the other stzCalendar
#   returns       a list of rows [ metric, this, other, difference ], headed by the two periods
#   note          the header row is [ metric, this period, other period, difference ]
#   warning       the difference is this minus the other; raises Incorrect param type! for anything
#                 but a stzCalendar; hours and working days share the holiday caveat of
#                 AvailableDaysN
#   see           Compare, CompareWithQR
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

	# Returns the comparison of two calendars wrapped in the object type named by the second argument.
	#
	#   _oOtherCal_    the other stzCalendar
	#   pcReturnType   the wanted class as a symbol: :stzList, :stzListOfLists or :stzTable
	#   returns        a stzList, stzListOfLists or stzTable object
	#   note           the content is that of CompareWith
	#   warning        any other type raises Insupported return type!; CompareWithQ, the call
	#                  without a type, raises R11 because stzListQ exists nowhere
	#   see            CompareWith
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

	# Returns the comparison of two calendars, the same rows as CompareWith.
	#
	#   _oOtherCal_   the other stzCalendar, or a pair [ :With, cal ] or [ :To, cal ]
	#   returns       a list of rows [ metric, this, other, difference ]
	#   warning       shares the caveats of CompareWith
	#   see           CompareWith
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

	# Clears the stored totals of available hours and days so the next question recounts them.
	#
	#   returns    nothing; the object changes in place
	#   note       AddHoliday, AddBreak, SetBusinessHours and SetWorkingDays already call it;
	#              navigation does not need it
	#   see        AvailableHoursN, AvailableDaysN
	def InvalidateCache()
		@nCachedAvailableHours = -1
		@nCachedAvailableDays = -1
		@cCachedStart = ""
		@cCachedEnd = ""


	  #------------------#
	 #  EXPORT METHODS  #
	#------------------#

	# Returns the calendar's settings and totals as a list of [ key, value ] pairs, not a hash.
	#
	#   returns    a list of pairs with lowercase keys
	#   note       the keys are startdate, enddate, year, month, quarter, totaldays, workingdays,
	#              availablehours, workingdayslist, holidays, breaks, businessstart, businessend;
	#              workingdayslist holds weekday numbers, Monday 1
	#   warning    the workingdays value is the available days (holidays removed on the first day
	#              only) and availablehours shares the caveats of AvailableHoursN
	#   see        ToJSON, Content
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
	
	# Returns the same facts as ToHash as JSON text, one key per line.
	#
	#   returns    a JSON text
	#   note       keys are lowercase; numbers are not quoted
	#   warning    text values are not escaped, so a quote inside a holiday name breaks the JSON
	#   see        ToHash, ToCSV
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
	
	# Returns the calendar's facts as CSV text, one line per fact, then one per holiday and per break.
	#
	#   returns    a CSV text
	#   note       ToCSVXT takes the separator; holiday lines hold date and name, break lines hold
	#              start, end and label
	#   warning    the first line is Metric,Value with a comma while the other lines use the
	#              separator ; (DefaultCSVSeperator), so the text mixes both
	#   see        ToJSON, ToHash
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

	# Sets the width used by the display, never below 40.
	#
	#   n          the wanted width in characters
	#   returns    nothing; the object changes in place
	#   note       a value under 40 becomes 40
	#   see        VizWidth, SetVizHeight
	#@ aka  Configuration
	def SetVizWidth(n)
		@nVizWidth = max([@nVizMinWidth, n])
		
	# Sets the height used by the display, never below 3.
	#
	#   n          the wanted height in rows
	#   returns    nothing; the object changes in place
	#   note       a value under 3 becomes 3; it can be lowered again
	#   see        VizHeight, SetVizWidth
	def SetVizHeight(n)
		# max() AGAINST ITSELF was a ratchet: the height could only ever go UP,
		# so SetVizHeight(20) then SetVizHeight(5) left 20 and the smaller value
		# was swallowed without a word. Its sibling SetVizWidth floors against a
		# MINIMUM, which is what was meant here too -- 3 rows, the floor this
		# class already applies when a height arrives through ToStringXT.
		@nVizHeight = max([@nVizMinHeight, n])
		
	# Returns the display width in characters.
	#
	#   returns    a number
	#   note       50 by default
	#   see        SetVizWidth
	def VizWidth()
		return @nVizWidth
		
	# Returns the display height in rows.
	#
	#   returns    a number
	#   note       10 by default
	#   see        SetVizHeight
	def VizHeight()
		return @nVizHeight


	# Main Display Methods (matching stzTimeLine pattern)

	def ShowXT(paOptions)
		? This.ToStringXT(paOptions)

	# Prints the month grid, its legend and the statistics table.
	#
	#   returns    nothing; it prints
	#   note       the same text as ToString
	#   warning    prints No calendar data to display above the table for a range or one-day
	#              calendar, and raises Not yet implemented! for a year or quarter calendar
	#   see        ToString, ShowShort
	def Show()
		? This.ToString()
		
	# Returns the month grid, its legend and the statistics table as one text, holidays as [D], days off as shaded blocks.
	#
	#   returns    a multi-line text
	#   note       the grid starts weeks on Monday; the statistics table repeats the holiday caveat
	#              of AvailableDaysN; ToStringXT with [ [ :ShowTable, 0 ] ] drops the table
	#   warning    raises Not yet implemented! for a year or quarter calendar (the overview calls
	#              AvailableHours); a range or one-day calendar gets No calendar data to display in
	#              place of the grid
	#   see        Show, ToStringShort
	def ToString()
		return This.ToStringXT([])
		
	# Prints the month grid and its legend, without the statistics table.
	#
	#   returns    nothing; it prints
	#   note       ToStringShort gives the same text
	#   warning    raises like ToString for a year or quarter calendar
	#   see        Show, ToString
	def ShowShort()
		? This.ToStringShort()

	def ToStringShort()
		return This._drawMonthGrid()

	def ToStringXT(paParams)
		_bShowTable_ = 1
		
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
				if @oTimeline != ""
					_cEventSymbol_ = _getTimelineSymbol(_cDate_)
				ok
				
				if This.IsHoliday(_cDate_)
					_cCell_ = "[" + PadLeftXT('' + _nDay_, 1, " ") + "]"
				but This.IsWorkingDay(_cDate_) = 0
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
		_cResult_ += char(10) + char(10) + _drawLegend()
		return _cResult_
	
	def _drawLegend()
		_cResult_ = "Legend:" + char(10)
	
		_aLegend_ = This.Legend()
		_nLen_ = len(_aLegend_)
	
		for _i_ = 1 to _nLen_
			_cResult_ += ("  " + _aLegend_[_i_][2] + " = " + Capitalise(_aLegend_[_i_][1]) )
			if _i_ < _nLen_
				_cResult_ += char(10)
			ok
		next
	
		return _cResult_
	
	# Returns the symbols the grid needs, as [ name, symbol ] pairs for holidays, days off and timeline events present.
	#
	#   returns    a list of pairs; [ ] when nothing needs one
	#   note       the holiday symbol is [D] and the day-off symbol is a shaded block; timeline
	#              symbols appear only with an attached timeline
	#   see        ToString, TimeLineEvents
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
		if @oTimeline = ""
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

	# Prints a bar per week of the month showing how many of its working days are available.
	#
	#   returns    nothing; it prints
	#   note       five shaded blocks mean a full working week
	#   warning    prints Heat map available only for monthly views for any other calendar; holidays
	#              after the first day are seen here, since the grid builds its own dates
	#   see        ToString, DetailedTable
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
	
	
	# Returns a header row and one row per day with its date, day name, business hours, break and available hours.
	#
	#   returns    a list of rows [ date, day, business, breaks, available ]
	#   note       DetailedTableQ answers a stzTable; the first break only is shown
	#   warning    numbers its days from the 1st of the start's month for as many days as the
	#              calendar spans, so a range or year calendar lists the wrong dates; holidays are
	#              seen (the dates are built here) and shown as HOLIDAY, days off as WEEKEND
	#   see        ShowTable, ToString
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
			but This.IsWorkingDay(_cDate_) = 0
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


		# Prints the detailed table of the month, with a title and a summary of days and hours.
		#
		#   returns    nothing; it prints
		#   note       the table is the one DetailedTable returns
		#   warning    shares the day-numbering caveat of DetailedTable; its summary counts working
		#              days with the holiday caveat of AvailableDaysN
		#   see        DetailedTable, Show
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

