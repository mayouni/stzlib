load "../../stzBase.ring"
load "../_narrated.ring"

# stzCalendar, the 25 methods the defect register listed (hour slots, available days and weeks,
# weekends, day and month navigation, GoTo, the clock accessors, ConflictsWithSpan). Every date
# below was worked out by hand on a calendar: 1 March 2026 is a Sunday, 29 February 2024 a Thursday,
# 29 February 2020 a Saturday, 31 December 2025 a Wednesday. Every positive has a negative sibling:
# a holiday, a Saturday, a non-leap February, a reversed range. Run from this folder:
#   ring stzCalendar_defects_narrated.ring

Scenario("Hour slots of one day: whole hours from the opening time, breaks and holidays left out")
	c = new stzCalendar("2026-03")
	c.AddHoliday("2026-03-10", "Fete")
	c.AddBreak("12:00:00", "13:00:00", "Lunch")
	aDay = c.AvailableHoursOn("2026-03-11")
	Then("a Wednesday with a one hour lunch has 7 slots", len(aDay), 7)
	Then("the first slot is the opening time", aDay[1], "2026-03-11 09:00:00")
	Then("the last slot starts an hour before closing", aDay[7], "2026-03-11 16:00:00")
	Then("the noon slot is gone", find(aDay, "2026-03-11 12:00:00"), 0)
	Then("the 13:00 slot is still there", find(aDay, "2026-03-11 13:00:00") > 0, 1)
	Then("the slot count agrees with AvailableHoursOnN", len(aDay), c.AvailableHoursOnN("2026-03-11"))
	Then("a date written dd/MM/yyyy gives the same first slot, in yyyy-MM-dd", c.AvailableHoursOn("11/03/2026")[1], "2026-03-11 09:00:00")
	Then("the holiday has no slot", len(c.AvailableHoursOn("2026-03-10")), 0)
	Then("a Saturday has no slot", len(c.AvailableHoursOn("2026-03-14")), 0)
	Then("a Sunday has no slot", len(c.AvailableHoursOn("2026-03-15")), 0)
	Then("the leap day 2024-02-29 (a Thursday) has 7 slots", len(c.AvailableHoursOn("2024-02-29")), 7)
	Then("the last day of the year (a Thursday) ends at 16:00", c.AvailableHoursOn("2026-12-31")[7], "2026-12-31 16:00:00")
	Then("ContainsAvailableHoursOn on a Wednesday", c.ContainsAvailableHoursOn("2026-03-11"), 1)
	Then("HasAvailableHoursOn on a Wednesday", c.HasAvailableHoursOn("2026-03-11"), 1)
	Then("ContainsAvailableHoursOn on the holiday", c.ContainsAvailableHoursOn("2026-03-10"), 0)
	Then("HasAvailableHoursOn on a Saturday", c.HasAvailableHoursOn("2026-03-14"), 0)
	cMsg = ""
	try
		c.AvailableHoursOn("not a date")
	catch
		cMsg = cCatchError
	done
	Then("a text that is no date raises, it does not invent a slot", len(cMsg) > 0, 1)
EndScenario()

Scenario("Slots follow the opening time and the break minutes")
	c = new stzCalendar("2026-03")
	c.SetBusinessHours("09:30:00", "17:30:00")
	aDay = c.AvailableHoursOn("2026-03-11")
	Then("opening at 09:30 gives 8 slots", len(aDay), 8)
	Then("the first starts at 09:30", aDay[1], "2026-03-11 09:30:00")
	Then("the last starts at 16:30", aDay[8], "2026-03-11 16:30:00")
	cShort = new stzCalendar("2026-03")
	cShort.SetBusinessHours("09:00:00", "09:45:00")
	Then("45 minutes of business hours hold no whole hour", len(cShort.AvailableHoursOn("2026-03-11")), 0)
	Then("so the day has no available hour", cShort.HasAvailableHoursOn("2026-03-11"), 0)
	cTwo = new stzCalendar("2026-03")
	cTwo.AddBreak("09:30:00", "09:40:00", "a")
	cTwo.AddBreak("11:30:00", "11:40:00", "b")
	Then("two ten-minute breaks in different hours drop two slots", len(cTwo.AvailableHoursOn("2026-03-11")), 6)
	Then("while AvailableHoursOnN takes minutes away first and keeps 7 (the documented difference)", cTwo.AvailableHoursOnN("2026-03-11"), 7)
EndScenario()

Scenario("Hour slots of a range cross a month, a year and a leap day")
	c = new stzCalendar("2026-03")
	c.AddBreak("12:00:00", "13:00:00", "Lunch")
	aMonth = c.AvailableHoursBetween("2026-02-27", "2026-03-03")
	Then("Friday 27 February, Monday 2 and Tuesday 3 March give 21 slots", len(aMonth), 21)
	Then("the first slot is on 27 February", aMonth[1], "2026-02-27 09:00:00")
	Then("the last slot is on 3 March", aMonth[21], "2026-03-03 16:00:00")
	Then("the 28 February and 1 March weekend adds nothing", find(aMonth, "2026-02-28 09:00:00") + find(aMonth, "2026-03-01 09:00:00"), 0)
	aYear = c.AvailableHoursBetween("2025-12-31", "2026-01-01")
	Then("31 December and 1 January give 14 slots", len(aYear), 14)
	Then("they start on the 31st", aYear[1], "2025-12-31 09:00:00")
	Then("they end on the 1st", aYear[14], "2026-01-01 16:00:00")
	aLeap = c.AvailableHoursBetween("2024-02-29", "2024-03-01")
	Then("29 February and 1 March 2024 give 14 slots", len(aLeap), 14)
	Then("the leap day is the first", aLeap[1], "2024-02-29 09:00:00")
	aPlain = c.AvailableHoursBetween("2025-02-28", "2025-03-03")
	Then("in 2025 Friday 28 February and Monday 3 March give 14 slots", len(aPlain), 14)
	Then("there is no 29 February in 2025", find(aPlain, "2025-02-29 09:00:00"), 0)
	Then("the last slot is on Monday 3 March", aPlain[14], "2025-03-03 16:00:00")
	Then("a range whose end comes before its start is empty", len(c.AvailableHoursBetween("2026-03-13", "2026-03-09")), 0)
	Then("a weekend range is empty", len(c.AvailableHoursBetween("2026-03-14", "2026-03-15")), 0)
	Then("HasAvailableHoursBetween over a working week", c.HasAvailableHoursBetween("2026-03-09", "2026-03-13"), 1)
	Then("HasAvailableHoursBetween over a weekend", c.HasAvailableHoursBetween("2026-03-14", "2026-03-15"), 0)
	c.AddHoliday("2026-03-10", "Fete")
	Then("HasAvailableHoursBetween over the holiday alone", c.HasAvailableHoursBetween("2026-03-10", "2026-03-10"), 0)
	Then("AvailableHours holds 21 days of 7 slots", len(c.AvailableHours()), 147)
	Then("AvailableHours agrees with AvailableHoursN", len(c.AvailableHours()), c.AvailableHoursN())
	aAll = c.AvailableHours()
	Then("the first slot of March 2026 is Monday the 2nd", aAll[1], "2026-03-02 09:00:00")
	Then("the last is Tuesday the 31st", aAll[147], "2026-03-31 16:00:00")
	Then("the holiday has no slot in the list", find(aAll, "2026-03-10 09:00:00"), 0)
	Then("neither has a Saturday", find(aAll, "2026-03-07 09:00:00"), 0)
EndScenario()

Scenario("Available days between two dates, at the month, year and leap-day boundaries")
	c = new stzCalendar(2026)
	c.AddHoliday("2026-01-01", "New year")
	aYear = c.AvailableDaysBetween("2025-12-29", "2026-01-02")
	Then("Monday 29 December to Friday 2 January is 5 weekdays, one of them a holiday: 4", J(aYear), "2025-12-29,2025-12-30,2025-12-31,2026-01-02")
	Then("the holiday is not listed", find(aYear, "2026-01-01"), 0)
	Then("AvailableDaysBetweenN counts the 4", c.AvailableDaysBetweenN("2025-12-29", "2026-01-02"), 4)
	Then("HowManyAvailableDaysBetween agrees", c.HowManyAvailableDaysBetween("2025-12-29", "2026-01-02"), 4)
	Then("CountAvailableDaysBetween agrees", c.CountAvailableDaysBetween("2025-12-29", "2026-01-02"), 4)
	Then("2024 is a leap year: Tuesday 27 February to Friday 1 March is 4 days", J(c.AvailableDaysBetween("2024-02-27", "2024-03-01")), "2024-02-27,2024-02-28,2024-02-29,2024-03-01")
	Then("2025 is not: Thursday 27 February to Monday 3 March is 3 days", J(c.AvailableDaysBetween("2025-02-27", "2025-03-03")), "2025-02-27,2025-02-28,2025-03-03")
	Then("so 2025-02-29 is never listed", find(c.AvailableDaysBetween("2025-02-27", "2025-03-03"), "2025-02-29"), 0)
	Then("and neither is the weekend 2025-03-01", find(c.AvailableDaysBetween("2025-02-27", "2025-03-03"), "2025-03-01"), 0)
	Then("a range written dd/MM/yyyy gives yyyy-MM-dd dates", J(c.AvailableDaysBetween("09/03/2026", "11/03/2026")), "2026-03-09,2026-03-10,2026-03-11")
	Then("a reversed range is empty", len(c.AvailableDaysBetween("2026-03-20", "2026-03-10")), 0)
	Then("and counts 0", c.AvailableDaysBetweenN("2026-03-20", "2026-03-10"), 0)
	Then("ContainsAvailableDaysBetween over a working week", c.ContainsAvailableDaysBetween("2026-03-09", "2026-03-13"), 1)
	Then("HasAvailableDaysBetween over one Monday", c.HasAvailableDaysBetween("2026-03-16", "2026-03-16"), 1)
	Then("ContainsAvailableDaysBetween over a weekend", c.ContainsAvailableDaysBetween("2026-03-14", "2026-03-15"), 0)
	Then("HasAvailableDaysBetween over the holiday alone", c.HasAvailableDaysBetween("2026-01-01", "2026-01-01"), 0)
EndScenario()

Scenario("Available weeks: Monday to Sunday weeks, each as its first and last available day")
	c = new stzCalendar("2026-03")
	c.AddHoliday("2026-03-10", "Fete")
	aWeeks = c.AvailableWeeks()
	Then("March 2026 has 5 weeks with an available day", len(aWeeks), 5)
	Then("the first runs Monday the 2nd to Friday the 6th", aWeeks[1][1] + " " + aWeeks[1][2], "2026-03-02 2026-03-06")
	Then("the last is cut by the end of the month", aWeeks[5][1] + " " + aWeeks[5][2], "2026-03-30 2026-03-31")
	cHol = new stzCalendar("2026-03")
	for d = 16 to 20
		cHol.AddHoliday("2026-03-" + d, "Closed")
	next
	aHol = cHol.AvailableWeeks()
	Then("a week made only of holidays is left out", len(aHol), 4)
	Then("the week of the 16th is not among them", find(aHol[3], "2026-03-16"), 0)
	Then("the next week follows it", aHol[3][1], "2026-03-23")
	cLeap = new stzCalendar("2024-02")
	aLeap = cLeap.AvailableWeeks()
	Then("February 2024 starts on a Thursday: its first week is two days", aLeap[1][1] + " " + aLeap[1][2], "2024-02-01 2024-02-02")
	Then("and ends on the leap day", aLeap[5][1] + " " + aLeap[5][2], "2024-02-26 2024-02-29")
	cPlain = new stzCalendar("2025-02")
	Then("February 2025 starts on a Saturday: 4 weeks", len(cPlain.AvailableWeeks()), 4)
	Then("the last ends on Friday the 28th", cPlain.AvailableWeeks()[4][2], "2025-02-28")
	cYear = new stzCalendar(2026)
	aY = cYear.AvailableWeeks()
	Then("the year 2026 touches 53 Monday weeks", len(aY), 53)
	Then("the first is Thursday 1 to Friday 2 January", aY[1][1] + " " + aY[1][2], "2026-01-01 2026-01-02")
	Then("the last is Monday 28 to Thursday 31 December", aY[53][1] + " " + aY[53][2], "2026-12-28 2026-12-31")
	cX = new stzCalendar([ [ "Start", "2025-12-29" ], [ "End", "2026-01-04" ] ])
	aX = cX.AvailableWeeks()
	Then("a week across the new year is one week", len(aX), 1)
	Then("from 29 December to 2 January", aX[1][1] + " " + aX[1][2], "2025-12-29 2026-01-02")
	cR = new stzCalendar([ [ "Start", "2026-03-04" ], [ "End", "2026-03-10" ] ])
	Then("Wednesday to Tuesday touches 2 weeks", len(cR.AvailableWeeks()), 2)
	Then("while AvailableWeeksN, 5 days over 5, says 1 (the documented difference)", cR.AvailableWeeksN(), 1)
EndScenario()

Scenario("Weekends between two dates follow the calendar's working days")
	c = new stzCalendar("2026-03")
	c.AddHoliday("2026-03-10", "Fete")
	Then("Friday 26 December to Monday 5 January holds two weekends", J(c.WeekendsBetween("2025-12-26", "2026-01-05")), "2025-12-27,2025-12-28,2026-01-03,2026-01-04")
	Then("WeekendsBetweenN counts the 4", c.WeekendsBetweenN("2025-12-26", "2026-01-05"), 4)
	Then("HowManyWeekendsBetween agrees", c.HowManyWeekendsBetween("2025-12-26", "2026-01-05"), 4)
	Then("Saturday 24 February to Sunday 3 March 2024 is 4 weekend days", c.WeekendsBetweenN("2024-02-24", "2024-03-03"), 4)
	Then("Saturday 29 February 2020 is a weekend day", J(c.WeekendsBetween("2020-02-28", "2020-03-01")), "2020-02-29,2020-03-01")
	Then("in 2021 there is no 29 February", J(c.WeekendsBetween("2021-02-28", "2021-03-01")), "2021-02-28")
	Then("a working week has no weekend day", c.WeekendsBetweenN("2026-03-02", "2026-03-06"), 0)
	Then("a holiday on a working weekday is not a weekend day", c.WeekendsBetweenN("2026-03-09", "2026-03-11"), 0)
	Then("a reversed range is empty", c.WeekendsBetweenN("2026-03-31", "2026-03-01"), 0)
	Then("the whole month holds 9 weekend days", c.WeekendsBetweenN("2026-03-01", "2026-03-31"), 9)
	cOff = new stzCalendar("2026-03")
	cOff.SetWorkingDays([ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday" ])
	Then("with Sunday to Thursday worked, the days off are Friday and Saturday", J(cOff.WeekendsBetween("2026-03-02", "2026-03-08")), "2026-03-06,2026-03-07")
	Then("and Sunday the 8th is not one of them", find(cOff.WeekendsBetween("2026-03-02", "2026-03-08"), "2026-03-08"), 0)
	Then("HasWeekends on a Monday", HasWE("2026-03-02"), 0)
	Then("HasWeekends on a Saturday", HasWE("2026-03-07"), 1)
	Then("HasWeekends on a Sunday", HasWE("2026-03-08"), 1)
	Then("HasWeekends on a whole month", c.HasWeekends(), 1)
	cFri = new stzCalendar("2026-03-06")
	cFri.SetWorkingDays([ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday" ])
	Then("HasWeekends on a Friday when Friday is a day off", cFri.HasWeekends(), 1)
	cSun = new stzCalendar("2026-03-08")
	cSun.SetWorkingDays([ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday" ])
	Then("HasWeekends on a Sunday when Sunday is worked", cSun.HasWeekends(), 0)
EndScenario()

Scenario("Day navigation on a calendar of one single day")
	c = new stzCalendar("2026-03-31")
	Then("the day after 31 March is 1 April", c.NextDay(), "2026-04-01")
	Then("NextDay does not move the calendar", c.Start() + " " + c.End_(), "2026-03-31 2026-03-31")
	Then("the day before 31 March is the 30th", c.PreviousDay(), "2026-03-30")
	Then("the day after 31 December is 1 January", (new stzCalendar("2026-12-31")).NextDay(), "2027-01-01")
	Then("the day before 1 January is 31 December", (new stzCalendar("2026-01-01")).PreviousDay(), "2025-12-31")
	Then("the day after 28 February 2024 is the leap day", (new stzCalendar("2024-02-28")).NextDay(), "2024-02-29")
	Then("the day after the leap day is 1 March", (new stzCalendar("2024-02-29")).NextDay(), "2024-03-01")
	Then("the day before 1 March 2024 is the leap day", (new stzCalendar("2024-03-01")).PreviousDay(), "2024-02-29")
	Then("the day after 28 February 2025 is 1 March, not a 29th", (new stzCalendar("2025-02-28")).NextDay(), "2025-03-01")
	Then("the day before 1 March 2025 is the 28th", (new stzCalendar("2025-03-01")).PreviousDay(), "2025-02-28")
	Then("a date written dd/MM/yyyy gives the next day in yyyy-MM-dd", (new stzCalendar("31/12/2026")).NextDay(), "2027-01-01")
	cMove = new stzCalendar("2026-12-30")
	cMove.GoToNextDay()
	Then("GoToNextDay moves the start", cMove.Start(), "2026-12-31")
	Then("and the end with it", cMove.End_(), "2026-12-31")
	Then("the calendar still covers one day", cMove.TotalDays(), 1)
	cMove.GotoNextDayQ().GoToNextDay()
	Then("two more steps cross the new year", cMove.Start() + " " + cMove.End_(), "2027-01-02 2027-01-02")
	cMove.GoToPreviousDay()
	Then("GoToPreviousDay steps back over the year boundary", cMove.Start(), "2027-01-01")
	cMove.GotoPreviousDayQ().GoToPreviousDay()
	Then("two more steps back", cMove.Start() + " " + cMove.End_(), "2026-12-30 2026-12-30")
	cLeap = new stzCalendar("2024-03-01")
	cLeap.GoToPreviousDay()
	Then("GoToPreviousDay from 1 March 2024 lands on the leap day", cLeap.Start(), "2024-02-29")
	cNo = new stzCalendar("2025-03-01")
	cNo.GoToPreviousDay()
	Then("and from 1 March 2025 on the 28th", cNo.Start(), "2025-02-28")
	cFri = new stzCalendar("2026-03-06")
	Then("a Friday has 8 available hours", cFri.AvailableHoursN(), 8)
	cFri.GoToNextDay()
	Then("after the move to Saturday the cached answer is not reused: 0 hours", cFri.AvailableHoursN(), 0)
	Then("and no available day", cFri.AvailableDaysN(), 0)
	cHol = new stzCalendar("2026-03-01")
	cHol.AddHoliday("2026-03-02", "Fete")
	cHol.GoToNextDay()
	Then("the holidays are kept: the day moved to is a holiday", cHol.IsHoliday(cHol.Start()), 1)
	Then("so it has no available day", cHol.AvailableDaysN(), 0)
	cHol.GoToNextDay()
	Then("the day after is a normal Tuesday", cHol.AvailableDaysN(), 1)
EndScenario()

Scenario("Day navigation refuses a period that has no current day, and leaves it as it was")
	cMonth = new stzCalendar("2026-03")
	cMsg = ""
	try
		cMonth.NextDay()
	catch
		cMsg = cCatchError
	done
	Then("NextDay on a month raises", StzFindFirst("one single day", cMsg) > 0, 1)
	cMsg = ""
	try
		cMonth.GoToNextDay()
	catch
		cMsg = cCatchError
	done
	Then("GoToNextDay on a month raises", StzFindFirst("one single day", cMsg) > 0, 1)
	Then("and the month is untouched", cMonth.Start() + " " + cMonth.End_(), "2026-03-01 2026-03-31")
	cMsg = ""
	try
		cMonth.PreviousDay()
	catch
		cMsg = cCatchError
	done
	Then("PreviousDay on a month raises", StzFindFirst("one single day", cMsg) > 0, 1)
	cMsg = ""
	try
		cMonth.GoToPreviousDay()
	catch
		cMsg = cCatchError
	done
	Then("GoToPreviousDay on a month raises", StzFindFirst("one single day", cMsg) > 0, 1)
	cRange = new stzCalendar([ [ "Start", "2026-03-10" ], [ "End", "2026-03-20" ] ])
	cMsg = ""
	try
		cRange.GoToNextDay()
	catch
		cMsg = cCatchError
	done
	Then("GoToNextDay on a range raises", StzFindFirst("one single day", cMsg) > 0, 1)
	Then("and the range is untouched", cRange.Start() + " " + cRange.End_(), "2026-03-10 2026-03-20")
	cYear = new stzCalendar(2026)
	cMsg = ""
	try
		cYear.NextDay()
	catch
		cMsg = cCatchError
	done
	Then("NextDay on a year raises", StzFindFirst("one single day", cMsg) > 0, 1)
	cEmpty = new stzCalendar([ "x", "y" ])
	cMsg = ""
	try
		cEmpty.NextDay()
	catch
		cMsg = cCatchError
	done
	Then("NextDay on a calendar that covers no date raises", StzFindFirst("covers no date", cMsg) > 0, 1)
EndScenario()

Scenario("GoToNext and GoTo move a calendar to another period")
	c = new stzCalendar("2026-12")
	c.GoToNext()
	Then("GoToNext from December goes to January of the next year", c.Start() + " " + c.End_(), "2027-01-01 2027-01-31")
	cLeap = new stzCalendar("2024-01")
	cLeap.GoToNext()
	Then("January 2024 goes to a February of 29 days", cLeap.Start() + " " + cLeap.End_(), "2024-02-01 2024-02-29")
	cPlain = new stzCalendar("2025-01")
	cPlain.GoToNext()
	Then("January 2025 goes to a February of 28 days", cPlain.Start() + " " + cPlain.End_(), "2025-02-01 2025-02-28")
	cChain = new stzCalendar("2026-11")
	cChain.GotoNextQ().GotoNextQ()
	Then("GotoNextQ chains across the new year", cChain.Start(), "2027-01-01")
	cYear = new stzCalendar(2026)
	cYear.GoToNext()
	Then("GoToNext on a year calendar changes nothing", cYear.Start() + " " + cYear.End_(), "2026-01-01 2026-12-31")
	cHol = new stzCalendar("2026-03")
	cHol.AddHoliday("2026-04-06", "Easter Monday")
	cHol.GoToNext()
	Then("holidays are kept through the move", cHol.IsHoliday("2026-04-06"), 1)
	Then("April 2026 then has 21 available days", cHol.AvailableDaysN(), 21)

	cGo = new stzCalendar([ 2026, 12 ])
	cGo.AddHoliday("2024-02-14", "Marker")
	cGo.GoTo("2024-02-29")
	Then("GoTo moves a month calendar to the month of a leap day", cGo.Start() + " " + cGo.End_(), "2024-02-01 2024-02-29")
	Then("it is the month of the date, February", cGo.MonthName(), "February")
	Then("holidays are kept", cGo.IsHoliday("2024-02-14"), 1)
	cGo.GoTo("29/02/2024")
	Then("the date can be written dd/MM/yyyy", cGo.Start(), "2024-02-01")
	cGo.GoTo("2025-02-10")
	Then("a February of 2025 ends on the 28th", cGo.End_(), "2025-02-28")
	cBack = new stzCalendar("2026-01")
	cBack.GoTo("2025-12-31")
	Then("going back over the year boundary", cBack.Start() + " " + cBack.End_(), "2025-12-01 2025-12-31")
	cY = new stzCalendar(2026)
	cY.GoTo("2024-02-29")
	Then("a year calendar goes to the year of the date", cY.Start() + " " + cY.End_(), "2024-01-01 2024-12-31")
	cQ = new stzCalendar("2026-Q2")
	cQ.GoTo("2027-11-05")
	Then("a quarter calendar goes to the quarter of the date", cQ.Start() + " " + cQ.End_(), "2027-10-01 2027-12-31")
	Then("which is the fourth", cQ.QuarterNumber(), 4)
	cQ.GoTo("2027-01-01")
	Then("1 January is in the first quarter", cQ.Start() + " " + cQ.End_(), "2027-01-01 2027-03-31")
	cRange = new stzCalendar([ [ "Start", "2026-03-10" ], [ "End", "2026-03-20" ] ])
	cMsg = ""
	try
		cRange.GoTo("2026-05-17")
	catch
		cMsg = cCatchError
	done
	Then("a range has no period to move: GoTo raises", StzFindFirst("GoTo needs a month", cMsg) > 0, 1)
	Then("and the range is untouched", cRange.Start() + " " + cRange.End_(), "2026-03-10 2026-03-20")
EndScenario()

Scenario("The Current accessors read the clock, not the calendar")
	c = new stzCalendar("2026-03")
	StzFreezeClock("2027-02-28 10:00:00")
	Then("the day of the month of the frozen clock", c.CurrentDay(), 28)
	Then("its month name", c.CurrentMonth(), "February")
	Then("its month number", c.CurrentMonthN(), 2)
	Then("its year", c.CurrentYear(), 2027)
	Then("the calendar's own year is not the clock's", c.Year() != c.CurrentYear(), 1)
	Then("nor is its month", c.MonthNumber() != c.CurrentMonthN(), 1)
	StzFreezeClock("2024-02-29")
	Then("on a leap day the day is 29", c.CurrentDay(), 29)
	Then("the month is February", c.CurrentMonth(), "February")
	StzFreezeClock("2025-12-31")
	Then("on the last day of the year the day is 31", c.CurrentDay(), 31)
	Then("the month is December", c.CurrentMonth(), "December")
	Then("number 12", c.CurrentMonthN(), 12)
	Then("the year 2025", c.CurrentYear(), 2025)
	StzFreezeClock("2026-01-01")
	Then("the next day is 1", c.CurrentDay(), 1)
	Then("January", c.CurrentMonth(), "January")
	Then("number 1", c.CurrentMonthN(), 1)
	Then("year 2026", c.CurrentYear(), 2026)
	cYear = new stzCalendar(2030)
	Then("another calendar gives the same clock year", cYear.CurrentYear(), 2026)
	StzUnfreezeClock()
	Then("unfrozen again, the clock is live", StzClockIsFrozen(), 0)
EndScenario()

Scenario("Conflicts of a named span with the holidays and days off")
	c = new stzCalendar("2026-03")
	c.AddHoliday("2026-03-10", "Fete")
	oTl = new stzTimeLine("2026-03-01", "2026-03-30")
	oTl.AddSpan("SPRINT", "2026-03-09", "2026-03-15")
	c.MarkTimeline(oTl)
	aConf = c.ConflictsWithSpan("SPRINT", [])
	Then("the span meets a holiday and a weekend: 3 conflicts", len(aConf), 3)
	Then("the holiday comes first, named", aConf[1][1] + " " + aConf[1][2], "2026-03-10 Holiday: Fete")
	Then("then the Saturday", aConf[2][1] + " " + aConf[2][2], "2026-03-14 Weekend")
	Then("then the Sunday", aConf[3][1] + " " + aConf[3][2], "2026-03-15 Weekend")
	Then("a label with no span has no conflict", len(c.ConflictsWithSpan("NOPE", [])), 0)
	Then("the label is compared as written: sprint does not find SPRINT", len(c.ConflictsWithSpan("sprint", [])), 0)
	cMsg = ""
	try
		(new stzCalendar("2026-03")).ConflictsWithSpan("SPRINT", [])
	catch
		cMsg = cCatchError
	done
	Then("with no timeline attached it raises the library's own message", StzFindFirst("stzTimeLine", cMsg) > 0, 1)

	cNy = new stzCalendar([ [ "Start", "2025-12-01" ], [ "End", "2026-01-31" ] ])
	cNy.AddHoliday("2026-01-01", "New year")
	oTl2 = new stzTimeLine("2025-12-01", "2026-01-30")
	oTl2.AddSpan("HOLIDAYS", "2025-12-30", "2026-01-04")
	cNy.MarkTimeline(oTl2)
	aNy = cNy.ConflictsWithSpan("HOLIDAYS", [])
	Then("a span over the new year meets the holiday and the weekend: 3 conflicts", len(aNy), 3)
	Then("the holiday of 1 January", aNy[1][1] + " " + aNy[1][2], "2026-01-01 Holiday: New year")
	Then("the Saturday 3 January", aNy[2][1], "2026-01-03")
	Then("the Sunday 4 January", aNy[3][1], "2026-01-04")
	Then("29 December, outside the span, is not reported", find(aNy[1], "2025-12-30"), 0)

	cLp = new stzCalendar([ [ "Start", "2024-02-01" ], [ "End", "2024-03-31" ] ])
	oTl3 = new stzTimeLine("2024-02-01", "2024-03-30")
	oTl3.AddSpan("LEAP", "2024-02-28", "2024-03-03")
	cLp.MarkTimeline(oTl3)
	aLp = cLp.ConflictsWithSpan("LEAP", [])
	Then("a span over the leap day: only the weekend of 2 and 3 March conflicts", len(aLp), 2)
	Then("the Saturday is 2 March", aLp[1][1], "2024-03-02")
	Then("the leap day itself, a Thursday, is no conflict", find(aLp[1], "2024-02-29") + find(aLp[2], "2024-02-29"), 0)
EndScenario()

Scenario("The year overview adds up the available days and hours of each month")
	cYear = new stzCalendar(2026)
	cText = cYear.ToString()
	Then("the overview of 2026 is drawn, it no longer raises", StzFindFirst("2026 Overview", cText) > 0, 1)
	Then("January 2026 has 22 working days of 8 hours", StzFindFirst("January(22d/176h)", cText) > 0, 1)
	Then("February 2026 has 20", StzFindFirst("February(20d/160h)", cText) > 0, 1)
	Then("July 2026 has 23", StzFindFirst("July(23d/184h)", cText) > 0, 1)
	Then("a March figure that is wrong is not there", StzFindFirst("March(21d", cText), 0)
	cLeap = new stzCalendar(2024)
	Then("February 2024, with its leap day, has 21 working days", StzFindFirst("February(21d/168h)", cLeap.ToString()) > 0, 1)
	cHol = new stzCalendar(2026)
	cHol.AddHoliday("2026-01-02", "Bridge")
	Then("a holiday takes a day and 8 hours off its month", StzFindFirst("January(21d/168h)", cHol.ToString()) > 0, 1)
EndScenario()

Summary()

func J(aList)
	cRes = ""
	nLen = len(aList)
	for i = 1 to nLen
		if i > 1
			cRes += ","
		ok
		cRes += aList[i]
	next
	return cRes

func HasWE(cDate)
	oCal = new stzCalendar(cDate)
	return oCal.HasWeekends()
