load "../../stzBase.ring"
load "../_narrated.ring"

# SplitAtCharsW and the :AtChars named param -- split at the chars matching a
# predicate. Engine-backed, no eval(). Migrated from the retired
# SplitAtCharsWXT / SplitWXT(:AtChars).

Scenario("SplitAtCharsW splits at the uppercase letters")
	Given('the string "RingRingRing"')
	Then("SplitAtCharsW", @@( Q("RingRingRing").SplitAtCharsW('Q(@char).IsUppercase()') ), @@([ "ing", "ing", "ing" ]))
	Then("SplitW(:AtChars) is the same", @@( Q("RingRingRing").SplitW(:AtChars = 'Q(@char).IsUppercase()') ), @@([ "ing", "ing", "ing" ]))
EndScenario()

Summary()
