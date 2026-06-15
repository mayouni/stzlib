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

Summary()
