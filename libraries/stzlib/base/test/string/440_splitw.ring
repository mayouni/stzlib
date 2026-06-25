load "../../stzBase.ring"
load "../_narrated.ring"

# SplitW with a POSITION predicate -- the char position is @i in the engine
# W-DSL. :At drops the matching positions; :After keeps them (splits after).
# Migrated from the retired SplitWXT (whose @position is now @i).

Scenario("SplitW splits on a position rule")
	Given('the string "RingRingRing" (12 chars)')
	Then("/ :At every 4th position drops it", @@( Q("RingRingRing").SplitW(:At = '@i % 4 = 0') ), @@([ "Rin", "Rin", "Rin" ]))
	Then(": After every 4th position keeps it", @@( Q("RingRingRing").SplitW(:After = '@i % 4 = 0') ), @@([ "Ring", "Ring", "Ring" ]))
EndScenario()

Summary()
