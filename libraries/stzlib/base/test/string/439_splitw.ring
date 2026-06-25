load "../../stzBase.ring"
load "../_narrated.ring"

# SplitW / SplitAtW -- split at the chars matching a predicate (dropping them).
# Engine-backed, no eval(). The :At named param is the same as the bare form.
# Migrated from the retired SplitWXT / SplitAtWXT.

Scenario("SplitW splits at the uppercase letters")
	Given('the string "RingRingRing"')
	Then("SplitW at uppercase drops the R's",
		@@( Q("RingRingRing").SplitW('Q(@char).IsUppercase()') ), @@([ "ing", "ing", "ing" ]))
	Then("SplitAtW is the same", @@( Q("RingRingRing").SplitAtW('Q(@char).IsUppercase()') ), @@([ "ing", "ing", "ing" ]))
	Then("the :At named param is the same",
		@@( Q("RingRingRing").SplitW(:At = 'Q(@char).IsUppercase()') ), @@([ "ing", "ing", "ing" ]))
EndScenario()

Summary()
