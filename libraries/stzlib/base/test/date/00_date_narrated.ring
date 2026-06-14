load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzDate -- built from a FIXED date
# string (no Today()/Tomorrow(), which are clock-dependent) so every
# assertion is deterministic. Default format is dd/mm/yyyy. Note: Day()
# returns the weekday NAME and Month() the month NAME; DayNumber()/
# MonthNumber() give the numbers.

Scenario("Components of 15/03/2024")
    Given("the date 15/03/2024 (a Friday)")
    o = StzDateQ("15/03/2024")
    Then("Date() round-trips the string", o.Date(), "15/03/2024")
    Then("Day() is the weekday name Friday", o.Day(), "Friday")
    Then("DayNumber() is 15", o.DayNumber(), 15)
    Then("Month() is March", o.Month(), "March")
    Then("MonthNumber() is 3", o.MonthNumber(), 3)
    Then("Year() is 2024", o.Year(), 2024)
    Then("DayOfYear() is 75 (leap-year Jan31+Feb29+15)", o.DayOfYear(), 75)
    Then("2024 IsLeapYear", o.IsLeapYear(), TRUE)
EndScenario()

Scenario("Non-leap year")
    Then("2023 is not a leap year", StzDateQ("01/01/2023").IsLeapYear(), FALSE)
EndScenario()

Scenario("Date arithmetic")
    Given("15/03/2024 as the base")
    o = StzDateQ("15/03/2024")
    o.AddDays(20)
    Then("+20 days crosses into April -> 04/04/2024", o.Date(), "04/04/2024")
    p = StzDateQ("15/03/2024")
    p.AddMonths(2)
    Then("+2 months -> 15/05/2024", p.Date(), "15/05/2024")
    q = StzDateQ("15/03/2024")
    q.AddYears(1)
    Then("+1 year -> 15/03/2025", q.Date(), "15/03/2025")
EndScenario()

Scenario("Span and comparison")
    Given("January 1st and 31st 2024")
    a = StzDateQ("01/01/2024")
    b = StzDateQ("31/01/2024")
    Then("DaysTo is 30", a.DaysTo(b), 30)
    Then("Jan 1 IsBefore Jan 31", a.IsBefore(b), TRUE)
    Then("Jan 1 IsAfter Jan 31 is FALSE", a.IsAfter(b), FALSE)
EndScenario()

Summary()
