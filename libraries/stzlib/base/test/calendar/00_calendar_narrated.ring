load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzCalendar -- month identity, working
# days and holiday management. Built from a FIXED [year, month] so every
# assertion is deterministic. (Show() is a visual renderer; not asserted.)

Scenario("Month identity for October 2024")
    Given("the calendar for 2024-10")
    o = new stzCalendar([2024, 10])
    Then("Year is 2024", o.Year(), 2024)
    Then("MonthName is October", o.MonthName(), "October")
    Then("TotalDays is 31", o.TotalDays(), 31)
EndScenario()

Scenario("Working days (Mon-Fri)")
    Given("a Mon-Fri working week in October 2024")
    o = new stzCalendar([2024, 10])
    o.SetWorkingDays([ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday" ])
    Then("Thu 2024-10-03 is a working day", o.IsWorkingDay("2024-10-03"), TRUE)
    Then("Sat 2024-10-05 is not a working day", o.IsWorkingDay("2024-10-05"), FALSE)
    Then("October 2024 has 23 working days", len(o.WorkingDays()), 23)
EndScenario()

Scenario("Holiday management")
    Given("a National Day holiday on 2024-10-15")
    o = new stzCalendar([2024, 10])
    o.AddHoliday("2024-10-15", "National Day")
    Then("2024-10-15 is a holiday", o.IsHoliday("2024-10-15"), TRUE)
    Then("2024-10-16 is not a holiday", o.IsHoliday("2024-10-16"), FALSE)
    Then("the holiday's name is read back", o.HolidayName("2024-10-15"), "National Day")
EndScenario()

Scenario("A viz dimension can be turned down as well as up")

	# -- WHY THIS SCENE EXISTS --
	#
	# SetVizHeight took max() AGAINST ITSELF -- max([@nVizHeight, n]) -- so the
	# height was a RATCHET: it could only ever go up, and a smaller value was
	# swallowed without a word. Its sibling SetVizWidth floors against a MINIMUM,
	# which is what was meant here too. The same line was in stzTimeLine, where
	# the width is really used to size a canvas.
	#
	# The example that demonstrates these setters could not see it: it only ever
	# raises the height (10 -> 20), and a ratchet and a working setter agree in
	# that direction.

	Given("a calendar at its default viz size")
	oVz = new stzCalendar(:Gregorian)
	Then("the height starts at 10", oVz.VizHeight(), 10)

	When("the height is raised and then LOWERED")
	oVz.SetVizHeight(20)
	Then("raising works, as it always did", oVz.VizHeight(), 20)
	oVz.SetVizHeight(5)
	Then("...and lowering works too", oVz.VizHeight(), 5)

	# THE FLOOR, which is what max() was there for: a height below the minimum
	# is raised to it rather than accepted. Without this the check above would
	# also pass if the setter simply assigned whatever it was handed.
	oVz.SetVizHeight(1)
	Then("a height under the minimum is floored at 3", oVz.VizHeight(), 3)

	# ...and the width keeps its own, larger floor -- the two are not the same
	# number, so neither check can stand in for the other.
	oVz.SetVizWidth(80)
	Then("the width takes a larger value", oVz.VizWidth(), 80)
	oVz.SetVizWidth(10)
	Then("...and floors at 40, not at 3", oVz.VizWidth(), 40)

	# The same ratchet was in stzTimeLine, where the width really does size the
	# drawing canvas -- so the fix is checked there too.
	Given("a timeline, whose width really is used to draw")
	oTl = new stzTimeLine("2024-01-01", "2024-12-31")
	oTl.SetVizHeight(20)
	oTl.SetVizHeight(5)
	Then("its height lowers as well", oTl.VizHeight(), 5)
	Then("...and floors the same way", VizHeightAfter(oTl, 1), 3)
	Then("...while its width still takes what it is given", VizWidthAfter(oTl, 80), 80)
EndScenario()

Summary()

func VizHeightAfter(poObj, pn)
	poObj.SetVizHeight(pn)
	return poObj.VizHeight()

func VizWidthAfter(poObj, pn)
	poObj.SetVizWidth(pn)
	return poObj.VizWidth()
