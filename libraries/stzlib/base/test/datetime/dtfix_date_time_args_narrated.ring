load "../../stzBase.ring"
load "../_narrated.ring"

# stzDate and stzTime: parameters overwritten before init read them (x = new stzDate(x) binds x to the
# new object first), list parameters changed in the caller, StzIsTime refusing two-digit parts,
# ToRelative reading the past as the future, the 12-hour forms keeping the 24-hour hour, ToHuman's
# quarter-to at the half-day marks. Run from this folder: ring dtfix_date_time_args_narrated.ring

Scenario("stzDate: a text, a list or a hash is accepted wherever another date is taken")
	d = new stzDate("2026-03-15")
	Then("MonthsTo takes a text", d.MonthsTo("2026-05-20"), 2)
	Then("YearsTo takes a text", d.YearsTo("2027-01-02"), 1)
	Then("IsSameMonth takes a text", d.IsSameMonth("2026-03-01"), 1)
	Then("IsSameMonth refuses another month", d.IsSameMonth("2026-04-01"), 0)
	Then("IsSameYear takes a text", d.IsSameYear("2026-12-31"), 1)
	Then("IsSameWeek takes a text", d.IsSameWeek("2026-03-14"), 1)
	Then("IsBetween takes two texts", d.IsBetween("2026-03-01", "2026-04-01"), 1)
	Then("IsBetween takes [ :And, text ] for the end", d.IsBetween("2026-03-01", [ :And, "2026-04-01" ]), 1)
	Then("IsBetween excludes a bound", d.IsBetween("2026-03-15", "2026-04-01"), 0)
	aList = [ 2026, 5, 20 ]
	Then("MonthsTo takes a list [ y, m, d ]", d.MonthsTo(aList), 2)
	Then("YearsTo takes a list", d.YearsTo(aList), 0)
	Then("IsSameYear takes a list", d.IsSameYear(aList), 1)
	aHash = [ :Year = 2027, :Month = 1, :Day = 2 ]
	Then("YearsTo takes a hash", d.YearsTo(aHash), 1)
	Then("MonthsTo takes a hash", d.MonthsTo(aHash), 10)
EndScenario()

Scenario("stzDate: a list or hash variable passed in is not replaced in the caller")
	d = new stzDate("2026-03-15")
	aList = [ 2026, 5, 20 ]
	d.DaysTo(aList)
	d.WeeksTo(aList)
	d.IsBefore(aList)
	d.IsAfter(aList)
	d.IsEqualTo(aList)
	d.IsEqual(aList)
	d.MonthsTo(aList)
	d.IsSameYear(aList)
	Then("the list is still a list", isList(aList), 1)
	Then("of three numbers", len(aList), 3)
	Then("ending with the day", aList[3], 20)
	aHash = [ :Year = 2027, :Month = 1, :Day = 2 ]
	d.DaysTo(aHash)
	d.IsBefore(aHash)
	Then("the hash is still a hash", isList(aHash), 1)
	Then("with its year", aHash[:Year], 2027)
	aEnd = [ :And, "2026-04-01" ]
	d.IsBetween("2026-03-01", aEnd)
	Then("the [ :And, x ] list survives IsBetween", len(aEnd), 2)
	Then("with its date", aEnd[2], "2026-04-01")
	Then("DaysTo answers the right distance for the list", d.DaysTo(aList), 66)
	cMsg = ""
	try
		d.DaysTo(5)
	catch
		cMsg = cCatchError
	done
	Then("DaysTo(5) raises", StzFindFirst("stzDate object or date string", cMsg) > 0, 1)
	cMsg = ""
	try
		d.MonthsTo(5)
	catch
		cMsg = cCatchError
	done
	Then("MonthsTo(5) raises the same message", StzFindFirst("stzDate object or date string", cMsg) > 0, 1)
EndScenario()

Scenario("stzDate: PreviousWeekday steps over the weekend from a Sunday too")
	d = new stzDate("2026-03-09")
	Then("a Monday gives the Friday", d.PreviousWeekday(), "06/03/2026")
	d = new stzDate("2026-03-08")
	Then("a Sunday gives the Friday, not the Saturday", d.PreviousWeekday(), "06/03/2026")
	d = new stzDate("2026-03-15")
	Then("another Sunday", d.PreviousWeekday(), "13/03/2026")
	d = new stzDate("2026-03-14")
	Then("a Saturday gives the day before", d.PreviousWeekday(), "13/03/2026")
	d = new stzDate("2026-03-11")
	Then("a Wednesday gives the Tuesday", d.PreviousWeekday(), "10/03/2026")
EndScenario()

Scenario("stzTime: StzIsTime accepts two-digit parts, so the operators accept a time text")
	Then("23:00", StzIsTime("23:00"), 1)
	Then("23:00:15", StzIsTime("23:00:15"), 1)
	Then("14:30:15.250", StzIsTime("14:30:15.250"), 1)
	Then("9:05", StzIsTime("9:05"), 1)
	Then("24:00 is out of range", StzIsTime("24:00"), 0)
	Then("12:60 is out of range", StzIsTime("12:60"), 0)
	Then("1a:00 holds a letter", StzIsTime("1a:00"), 0)
	Then("an empty part is refused", StzIsTime("12::00"), 0)
	o = new stzTime("10:00:00")
	Then("time minus a time text is the seconds from the text to the time", o - "09:30:00", 1800)
	Then("< with a time text", o < "23:00:00", 1)
	Then("> with a time text", o > "23:00:00", 0)
	Then("= with a time text", o = "10:00:00", 1)
	Then("<= with a time text", o <= "10:00:00", 1)
EndScenario()

Scenario("stzTime: MSecsTo reads a time text, and IsBetween leaves its list alone")
	o = new stzTime("10:00:00")
	Then("MSecsTo a text with milliseconds", o.MSecsTo("10:00:01.500"), 1500)
	Then("MSecsTo another text answers another number", o.MSecsTo("12:00:00"), 7200000)
	oOther = new stzTime("10:00:02")
	Then("MSecsTo a time object", o.MSecsTo(oOther), 2000)
	aEnd = [ :And, "11:00:00" ]
	Then("IsBetween takes [ :And, text ]", o.IsBetween("09:00:00", aEnd), 1)
	Then("and the list is still the list", aEnd[2], "11:00:00")
	oZero = new stzTime(0)
	Then("new stzTime(0) is midnight, not the clock", oZero.ToString(), "00:00:00")
EndScenario()

Scenario("stzTime: the 12-hour forms convert the hour")
	o = new stzTime("14:30:00")
	Then("To12Hour", o.To12Hour(), "2:30:00 PM")
	Then("ToSimple", o.ToSimple(), "2:30 PM")
	Then("ToStringXT with h:mm AP", o.ToStringXT("h:mm AP"), "2:30 PM")
	Then("ToStringXT with hh:mm AP pads the 12-hour hour", o.ToStringXT("hh:mm AP"), "02:30 PM")
	Then("ToStringXT :AmPm", o.ToStringXT(:AmPm), "2:30:00 PM")
	Then("a 24-hour format keeps the 24-hour hour", o.ToStringXT("HH:mm"), "14:30")
	Then("hh without AP is still the 24-hour hour", o.ToShort(), "14:30")
	o = new stzTime("00:05:09")
	Then("00:05 is 12:05 AM, not 0:05 AM", o.To12Hour(), "12:05:09 AM")
	Then("ToSimple at 00:05", o.ToSimple(), "12:05 AM")
	o = new stzTime("12:00:00")
	Then("noon is 12 PM", o.To12Hour(), "12:00:00 PM")
EndScenario()

Scenario("stzTime: ToHuman says the next hour on its own clock at the quarter-to")
	o = new stzTime("11:45:00")
	Then("11:45", o.ToHuman(), "Quarter to 12 PM")
	o = new stzTime("12:45:00")
	Then("12:45", o.ToHuman(), "Quarter to 1 PM")
	o = new stzTime("23:45:00")
	Then("23:45", o.ToHuman(), "Quarter to 12 AM")
	o = new stzTime("00:45:00")
	Then("00:45", o.ToHuman(), "Quarter to 1 AM")
	o = new stzTime("14:45:00")
	Then("14:45 (always right)", o.ToHuman(), "Quarter to 3 PM")
	o = new stzTime("14:30:00")
	Then("a half past is unchanged", o.ToHuman(), "Half past 2 PM")
EndScenario()

Scenario("stzTime: ToRelative reads a past time as past and a future time as future")
	oNow = new stzTime("")
	nHour = oNow.Hour()
	oPast = new stzTime("" + ((nHour + 23) % 24) + ":" + oNow.Minute() + ":00")
	oFuture = new stzTime("" + ((nHour + 2) % 24) + ":" + oNow.Minute() + ":00")
	# the clock can pass midnight between the two readings; both words need a whole hour of margin
	cPast = oPast.ToRelative()
	cFuture = oFuture.ToRelative()
	Then("the past hour reads 1 hour ago when the day does not wrap", (nHour = 0 or StzFindFirst("ago", cPast) > 0), 1)
	# two hours ahead minus the seconds already run reads 1 hour (or 2 when the seconds are exactly 0)
	Then("the future reads in N hours when the day does not wrap", (nHour >= 22 or (StzFindFirst("in ", cFuture) = 1 and StzFindFirst("hour", cFuture) > 0)), 1)
EndScenario()

Scenario("stzDate: ToHuman writes the future in lowercase like the past")
	o = new stzDate("")
	o.AddDays(3)
	Then("three days ahead", o.ToHuman(), "in 3 days")
	o = new stzDate("")
	o.SubtractDays(3)
	Then("three days back", o.ToHuman(), "3 days ago")
EndScenario()

Summary()
