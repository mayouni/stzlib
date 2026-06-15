load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzNumbrex -- number-property pattern
# matching, e.g. "{@Property(Prime)}".Match(n). Deterministic.
#
# Regression guard: Match() previously returned TRUE for EVERY input
# because the pattern parser used @StzMid with end-based args while the
# global @StzMid is count-based -- so tokens never parsed and MatchTokens
# looped over an empty list. Fixed via an end-based _Mid() helper. Each
# property is therefore tested with BOTH a matching and a non-matching n.

Scenario("Prime")
    Then("17 is prime", Nbx("{@Property(Prime)}").Match(17), TRUE)
    Then("18 is not prime", Nbx("{@Property(Prime)}").Match(18), FALSE)
EndScenario()

Scenario("Perfect")
    Then("6 is perfect", Nbx("{@Property(Perfect)}").Match(6), TRUE)
    Then("28 is perfect", Nbx("{@Property(Perfect)}").Match(28), TRUE)
    Then("12 is not perfect", Nbx("{@Property(Perfect)}").Match(12), FALSE)
EndScenario()

Scenario("Fibonacci")
    Then("13 is fibonacci", Nbx("{@Property(Fibonacci)}").Match(13), TRUE)
    Then("22 is not fibonacci", Nbx("{@Property(Fibonacci)}").Match(22), FALSE)
EndScenario()

Scenario("Even / Odd")
    Then("4 is even", Nbx("{@Property(Even)}").Match(4), TRUE)
    Then("5 is not even", Nbx("{@Property(Even)}").Match(5), FALSE)
    Then("7 is odd", Nbx("{@Property(Odd)}").Match(7), TRUE)
EndScenario()

Scenario("Square / Composite / Positive")
    Then("16 is a square", Nbx("{@Property(Square)}").Match(16), TRUE)
    Then("15 is not a square", Nbx("{@Property(Square)}").Match(15), FALSE)
    Then("9 is composite", Nbx("{@Property(Composite)}").Match(9), TRUE)
    Then("5 is positive", Nbx("{@Property(Positive)}").Match(5), TRUE)
    Then("-5 is not positive", Nbx("{@Property(Positive)}").Match(-5), FALSE)
EndScenario()

Summary()

func Nbx cPattern
    return new stzNumbrex(cPattern)
