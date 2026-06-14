load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzDuration -- durations built from
# seconds or natural-language strings, with components, arithmetic,
# comparisons, and formatting. All deterministic.

Scenario("Create a duration from seconds")
    Then("3665s -> 1:01:05", Dur(3665).Content(), "1:01:05")
EndScenario()

Scenario("Retrieve duration components")
    Given("the duration '2 days 5 hours 30 minutes 45 seconds'")
    o = Dur("2 days 5 hours 30 minutes 45 seconds")
    Then("Days() is 2",            o.Days(), 2)
    Then("Hours() is 5",           o.Hours(), 5)
    Then("Minutes() is 30",        o.Minutes(), 30)
    Then("Seconds() is 45",        o.Seconds(), 45)
    Then("TotalHours() is 53",     o.TotalHours(), 53)
    Then("TotalMinutes() is 3210", o.TotalMinutes(), 3210)
    Then("TotalSeconds() is 192645", o.TotalSeconds(), 192645)
EndScenario()

Scenario("Arithmetic on durations")
    Given("a one-hour base duration")
    d1 = DurationQ("1 hour")
    Then("1 hour + 1800 seconds -> 1 hour and 30 minutes", (d1 + 1800).ToHuman(), "1 hour and 30 minutes")
    Then("1 hour + '45 minutes' -> 1 hour and 45 minutes", (d1 + "45 minutes").ToHuman(), "1 hour and 45 minutes")
    Then("3 hours - '1 hour 15 minutes' -> 1 hour and 45 minutes", (DurationQ("3 hours") - "1 hour 15 minutes").ToHuman(), "1 hour and 45 minutes")
    Then("'45 minutes' * 3 -> 2 hours and 15 minutes", (DurationQ("45 minutes") * 3).ToHuman(), "2 hours and 15 minutes")
    Then("'2 hours' / 4 -> 30 minutes", (DurationQ("2 hours") / 4).ToHuman(), "30 minutes")
EndScenario()

Scenario("Compare durations")
    Given("1 hour vs 90 minutes")
    d1 = DurationQ("1 hour")
    d2 = DurationQ("90 minutes")
    Then("1 hour < 90 minutes", (d1 < d2), TRUE)
    Then("1 hour = '1 hour'", (d1 = "1 hour"), TRUE)
    Then("90 minutes > 3600 seconds", (d2 > 3600), TRUE)
    Then("IsLessThan", d1.IsLessThan(d2), TRUE)
    Then("IsGreaterThan('1 hour')", d2.IsGreaterThan("1 hour"), TRUE)
    Then("IsEqualTo(3600)", d1.IsEqualTo(3600), TRUE)
    Then("75 minutes IsBetween 1 and 2 hours", DurationQ("75 minutes").IsBetween("1 hour", "2 hours"), TRUE)
EndScenario()

Scenario("Format a duration")
    Given("the duration '3 hours 25 minutes 42 seconds'")
    o = Dur("3 hours 25 minutes 42 seconds")
    Then("ToString -> 3:25:42",      o.ToString(), "3:25:42")
    Then("ToStringXT HH:mm:ss -> 03:25:42", o.ToStringXT("HH:mm:ss"), "03:25:42")
    Then("ToHuman -> 3 hours, 25 minutes, and 42 seconds", o.ToHuman(), "3 hours, 25 minutes, and 42 seconds")
    Then("ToCompact -> 3h 25m 42s", o.ToCompact(), "3h 25m 42s")
    Then("ToSimple -> 3:25:42",      o.ToSimple(), "3:25:42")
EndScenario()

Scenario("Mutate a duration in place")
    Given("a one-hour duration")
    m = Dur("1 hour")
    When("30 minutes are added")
    m.AddMinutes(30)
    Then("ToHuman -> 1 hour and 30 minutes", m.ToHuman(), "1 hour and 30 minutes")
    When("2 hours are added")
    m.AddHours(2)
    Then("ToHuman -> 3 hours and 30 minutes", m.ToHuman(), "3 hours and 30 minutes")
    When("30 minutes are subtracted")
    m.Subtract("30 minutes")
    Then("ToHuman -> 3 hours", m.ToHuman(), "3 hours")
EndScenario()

Summary()

func Dur p
    return new stzDuration(p)
