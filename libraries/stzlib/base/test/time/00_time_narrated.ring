load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzTime -- built from FIXED time
# strings (no clock-dependent Now()/NowTime()) so every assertion is
# deterministic. Format is HH:mm:ss; a HH:mm input is normalised to :00.

Scenario("Construction and components")
    Given("the time 14:30:45")
    o = new stzTime("14:30:45")
    Then("Content round-trips", o.Content(), "14:30:45")
    Then("Hours is 14", o.Hours(), 14)
    Then("Minutes is 30", o.Minutes(), 30)
    Then("Seconds is 45", o.Seconds(), 45)
    Then("'14:30' normalises to 14:30:00", (new stzTime("14:30")).Content(), "14:30:00")
EndScenario()

Scenario("Arithmetic")
    Given("14:30:45 as the base")
    o = new stzTime("14:30:45")
    o.AddHours(2)
    Then("+2 hours -> 16:30:45", o.Content(), "16:30:45")
    o.AddMinutes(45)
    Then("+45 minutes rolls into the next hour -> 17:15:45", o.Content(), "17:15:45")
EndScenario()

Scenario("Comparison and parts of day")
    Given("09:00 vs 17:30")
    a = new stzTime("09:00:00")
    b = new stzTime("17:30:00")
    Then("09:00 IsBefore 17:30", a.IsBefore(b), TRUE)
    Then("09:00 IsAfter 17:30 is FALSE", a.IsAfter(b), FALSE)
    Then("14:30 is afternoon", (new stzTime("14:30:00")).IsAfternoon(), TRUE)
    Then("09:00 is not afternoon", (new stzTime("09:00:00")).IsAfternoon(), FALSE)
    Then("14:30 is 2 on a 12-hour clock", (new stzTime("14:30:00")).Hours12(), 2)
EndScenario()

Summary()
