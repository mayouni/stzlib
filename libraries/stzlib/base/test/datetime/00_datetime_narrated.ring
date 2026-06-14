load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzDateTime -- built from a FIXED
# timestamp (no Now()/NowXT(), which are clock-dependent) so assertions are
# deterministic. Standard format is "yyyy-mm-dd hh:mm:ss".

Scenario("Construct and format")
    Given("the timestamp 2024-03-15 10:30:00")
    o = StzDateTimeQ("2024-03-15 10:30:00")
    Then("Content round-trips", o.Content(), "2024-03-15 10:30:00")
    Then("ToEuropean is dd/mm/yyyy 12h AM/PM", o.ToEuropean(), "15/03/2024 10:30:00 AM")
    Then("ToEuropeanWithoutAmPm is 24h", o.ToEuropeanWithoutAmPm(), "15/03/2024 10:30:00")
EndScenario()

Scenario("Components")
    Given("the timestamp 2024-03-15 10:30:45")
    o = StzDateTimeQ("2024-03-15 10:30:45")
    Then("Year is 2024", o.Year(), 2024)
    Then("Month is 3", o.Month(), 3)
    Then("Day is 15", o.Day(), 15)
    Then("Hours is 10", o.Hours(), 10)
    Then("Minutes is 30", o.Minutes(), 30)
    Then("Seconds is 45", o.Seconds(), 45)
EndScenario()

Scenario("Arithmetic")
    Given("2024-03-15 10:30:45")
    o = StzDateTimeQ("2024-03-15 10:30:45")
    o.AddHours(2)
    Then("+2 hours -> 12:30:45", o.Content(), "2024-03-15 12:30:45")
    o.AddDays(1)
    Then("+1 day -> next day same time", o.Content(), "2024-03-16 12:30:45")
EndScenario()

Scenario("Comparison")
    Given("10:00 and 12:00 on the same day")
    a = StzDateTimeQ("2024-03-15 10:00:00")
    b = StzDateTimeQ("2024-03-15 12:00:00")
    Then("10:00 IsBefore 12:00", a.IsBefore(b), TRUE)
    Then("10:00 IsAfter 12:00 is FALSE", a.IsAfter(b), FALSE)
EndScenario()

Summary()
