# defects (method: symptom: cause) -- wave 3, stzDate / stzTime / stzCalendar (each seen on at least two calls unless marked [1])

## stzDate
- MonthsTo, YearsTo, IsSameWeek, IsSameMonth, IsSameYear, IsBetween: raise for a text, list or hash argument (R "Can't create the stzDate object" or "Cannot parse date string: --"); only a stzDate object works: `x = new stzDate(x...)` assigns the object to the parameter before init reads it
- DaysTo, WeeksTo, IsBefore, IsAfter, IsEqualTo, IsEqual: a list or hash VARIABLE passed in is replaced in the caller by a stzDate object (Ring passes lists by reference, the body assigns to its parameter) [list x4 methods, hash x1]
- PreviousWeekday: a Sunday gives the Saturday (07/03, 28/02, 21/03 from three Sundays): only a Monday steps back 3 days
- Age: counts year numbers only (1990-12-31 is 36 on 2026-03-15); future dates give a positive count
- MonthInLanguage, DayInLanguage, MonthIn, DayIn: "French"/"Arabic" with a capital fall back to English; only lowercase text or a symbol works (table keys are lowercase, string = is case-sensitive here)
- init/SetDate: list or hash is not validated ([2026,13,45] accepted); SetDate("2026-02-30") raises AFTER overwriting the fields; "in 3 fortnights" leaves the date empty (init) or unchanged (SetDate) with no error; two-digit year raises R41; 2-item list or a number raises "must provide a string"
- AddMonths, AddYears (and Subtract forms): a fractional count gives 2026-3.50-15 / 2026.50-03-15
- FromJulianDay: a fractional number gives a fractional day (2000-01-1.50)
- ToString family: the year is not padded below 1000 (999-05-05)
- operator: + with a list answers nothing; date - date is the absolute number of days
- ExtractValueAndUnit: a doubled space gives an empty unit; non-numeric number raises R41
- week numbers are not ISO (2025-12-31 is week 53, 2024-12-30 is week 53)
- pre-1970 dates: NO defect (1955-07-04, 1900-01-01, 1600-02-29 all correct, also arithmetic and Julian round trip)

## stzTime
- init: the number 0 reads the current clock instead of midnight (0 = "" in Ring) [new stzTime(0) x3 samples, same for 0.0]
- init: fractional seconds number gives "01:01:1.50"; "2:30pm" (no space) raises R41; a plain list [8,5,9] is ignored (00:00:00); ".5" is 5 ms not 500 (digits after the dot read as a whole number)
- init/clock: the engine clock showed 11:50:19 while Ring time() showed 12:50:19 (UTC offset) [2 samples]
- StzIsTime answers FALSE for every text with a two-digit part ("23:00", "23:00:00"): isdigit() tests one character; so operator "-" and every comparison operator with a time TEXT answer nothing [4 samples]
- MSecsTo: a time text is read as 00:00:00 (same answer for six different texts): the parameter is overwritten by `new stzTime(...)` before it is read
- ToRelative: direction reversed (10 min earlier reads "in 10 minutes", 5 h later reads "5 hours ago") [4 samples]
- To12Hour, ToSimple, ToStringXT "h:mm AP": the hour is not converted (14:30:00 PM, 0:05:09 AM)
- ToHuman: quarter-to form wrong at 11:45, 12:45, 23:45, 00:45 (Quarter to 13 PM, Quarter to 12 AM)
- pvtFormatTime: a quoted literal h in "hh 'h' mm" is replaced too
- IsBefore, IsAfter, IsEqualTo, SecsTo, MinutesTo, HoursTo: milliseconds ignored (14:30:15.500 equals 14:30:15.900)
- AddSeconds fractional result leaves "12:00:0.50"

## stzCalendar
- AvailableHours, AvailableHoursBetween, AvailableHoursOn, AvailableDaysBetween, AvailableWeeks, WeekendsBetween, NextDay, GoToNextDay, PreviousDay, GoToPreviousDay, GoTo: stubs, raise "Not yet implemented!" [each called once; distinct bodies read]
- WeekendsBetweenN, ContainsAvailableHoursOn, HasAvailableHoursOn, HasAvailableHoursBetween: raise "Not yet implemented!" through their stub
- AvailableDaysBetweenN, ContainsAvailableDaysBetween, HasAvailableDaysBetween: R14, call AvailabelDaysBetween (misspelled)
- GoToNext: R14, calls GoNextMonth
- BreaksBetween, BreaksBetweenN, HowManyBreaksBetween, CountBreaksBetween, HasBreaksBetween, CountAvailableHoursBetween: R41 as soon as one break exists (break time read as a date); ContainsBreaksBetween: R14 always (`This. reaksBetween`); the source also has `@a Breaks`
- WorkingDaysBetween, WorkingDaysBetweenN, ContainsWorkingDaysBetween, HasWorkingDaysBetween: R5 as soon as working days are set (each weekday number indexed as a list); [ ] / 0 only on a calendar with none set
- ConflictsWithSpan: R24 for every label (tests undefined oTimeLine, not @oTimeline)
- ContainsBusinessHours, HasBusinessHours: always FALSE (test is start != "" and end = "")
- HasWeekends: no body, answers nothing; HasHolidays, HasBreaks, HasWorkingDaysBetween, HasBreaksBetween: answer a count, not TRUE/FALSE
- holidays after the first day are not recognised when days are counted: the walk uses stzDate.NextDay (dd/MM/yyyy text) and IsHoliday compares text with the ISO date as added: AvailableDaysN, AvailableDays, AvailableHoursN, AvailableHoursBetweenN, AvailableMinutes(N), AvailableWeeksN, FreeDays*, ConsecutiveWorkingDaysAvailable*, FirstAvailableSlot, RangeInfo, ToHash/ToJSON/ToCSV, CompareWith, ApplyConstraints/CanFit/AvailableHoursOnN/DateInfo/IsHoliday/HolidayName given dd/MM/yyyy; ConflictsWith inside spans [holiday on middle day: 22 days instead of 21 in March 2026, AvailableHoursN 176 instead of 168; holiday on first day IS removed]
- AvailableHoursBetweenN stores its sub-range total in the whole-calendar cache: AvailableHoursN then answers it (154 -> 35; 176 -> 24)
- FirstAvailableSlot: end counted from midnight (09:00:00 .. 04:00:00 for 4 h) [2 samples]; Minutes() of stzTime is the minute part
- ConsecutiveWorkingDaysAvailable: walks one day past the calendar end (03-30 lists 01/04/2026; 03-31 lists 01/04/2026)
- Next_/NextMonth in December: raises "Invalid date provided!" (month 13); GotoNextMonth in December: raises R2 after leaving month 13 / year moved
- GoToNextYear, GoToPreviousYear: keep month/quarter; a range calendar ends in year 1 / -1
- MarkTimeline: warning printed also when the timeline ends on the calendar's last day (23:59:59 > 00:00 of that day) [2 samples; strictly inside prints nothing]
- DetailedTable (and ShowTable): rows numbered from the 1st of the start's month for TotalDays rows, wrong for a range [range 03-10..03-20 lists 03-01..03-11]
- ToString/Show/ShowShort: year or quarter calendar raises "Not yet implemented!" (compact year calls AvailableHours) [year, quarter]; range or one-day calendar prints "No calendar data to display"
- ToCSV: first line "Metric,Value" comma, the rest ";" 
- CompareWithQ: R11 (stzListQ exists nowhere); CompareWithQR other type: "Insupported return type!"
- Copy: constraints, timeline, viz sizes not copied
- init: year <= 1900 raises; "2026-q4" lowercase raises R41; [2026,"Spring"] gives the whole year; [2026,13] and [] raise R2; two-date list leaves the calendar empty; the "lLocale" key can never match (key is lowercased first)
- AddHoliday / AddBreak: all arguments required (R19 with fewer)
- SetWorkingDays: text other than DEFAULT and numbers ignored; TotalDays negative for a reversed range
- TotalWeeks / AvailableWeeksN: ceil(days/7) and ceil(available/5), not calendar weeks
