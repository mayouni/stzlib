load "../../stzBase.ring"
load "../_narrated.ring"

# The Verbose family printed the day of the month as the letter d (Sunday, March d, 2026): the single d
# of the pattern was never replaced, and could not be replaced after the names went in, because
# Sunday and December contain a d. Run from this folder: ring dtfix_verbose_narrated.ring

Scenario("The day number is printed, on a one-digit day and on a two-digit day")
	o = new stzDateTime("2026-03-05 14:30:00")
	Then("ToVerbose", o.ToVerbose(), "Thursday, March 5, 2026 02:30:00 PM")
	Then("ToVerbose12h", o.ToVerbose12h(), "Thursday, March 5, 2026 02:30:00 PM")
	Then("ToVerboseAP", o.ToVerboseAP(), "Thursday, March 5, 2026 02:30:00 PM")
	Then("ToVerboseAmPm", o.ToVerboseAmPm(), "Thursday, March 5, 2026 02:30:00 PM")
	Then("ToVerboseWithAP", o.ToVerboseWithAP(), "Thursday, March 5, 2026 02:30:00 PM")
	Then("ToVerboseWithAmPm", o.ToVerboseWithAmPm(), "Thursday, March 5, 2026 02:30:00 PM")
	Then("ToVerbose24h", o.ToVerbose24h(), "Thursday, March 5, 2026 14:30:00")
	Then("ToVerboseWithoutAP", o.ToVerboseWithoutAP(), "Thursday, March 5, 2026 14:30:00")
	Then("ToVerboseWithoutAmPm", o.ToVerboseWithoutAmPm(), "Thursday, March 5, 2026 14:30:00")
	Then("ToLong24h", o.ToLong24h(), "Thursday, March 5, 2026 14:30:00")
	Then("ToLongDate", o.ToLongDate(), "Thursday, March 5, 2026")
	Then("ToTextDate", o.ToTextDate(), "Thu Mar 5 14:30:00 2026")
	Then("ToLong, which always worked, prints the same day", StzFindFirst("March 5, 2026", o.ToLong()) > 0, 1)
	o2 = new stzDateTime("2026-03-15 14:30:00")
	Then("a two-digit day is printed whole", o2.ToVerbose24h(), "Sunday, March 15, 2026 14:30:00")
EndScenario()

Scenario("Names that contain the letter d are not corrupted by the day number")
	o = new stzDateTime("2026-12-23 09:05:00")
	Then("Wednesday in December", o.ToLongDate(), "Wednesday, December 23, 2026")
	o2 = new stzDateTime("2026-12-02 09:05:00")
	Then("Wednesday the 2nd keeps its two d letters apart", o2.ToLongDate(), "Wednesday, December 2, 2026")
	Then("the padded dd token still pads", o2.ToStringXT("dd/MM/yyyy"), "02/12/2026")
	Then("dddd and ddd still give the day names", o2.ToStringXT("dddd ddd"), "Wednesday Wed")
	Then("a d inside a word of the format is left as text", o2.ToStringXT("Day dd"), "Day 02")
	Then("a lone d between spaces is the day without padding", o2.ToStringXT("d MMM"), "2 Dec")
EndScenario()

Scenario("The year is padded to four digits")
	o = new stzDateTime("2026-03-05 14:30:00")
	o.FromDaysSinceEpoch(-719162)
	Then("year 1 prints as 0001", o.ToIso(), "0001-01-01 00:00:00")
EndScenario()

Summary()
