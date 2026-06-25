load "../../stzBase.ring"
load "../_narrated.ring"

# Splitting around / before / after a substring. These are the direct literal
# forms; they replace the retired SplitWXT(:AroundSubString/:BeforeSubString/
# :AfterSubString) predicate dispatch (whose @substring=="lit" reduces to the
# literal split).

Scenario("Split a string at a substring boundary")
	Given('the string "JuliaRingRuby"')
	Then("SplitAround drops the substring", @@( Q("JuliaRingRuby").SplitAround("Ring") ), @@([ "Julia", "Ruby" ]))
	Then("SplitBefore keeps it with the right piece", @@( Q("JuliaRingRuby").SplitBefore("Ring") ), @@([ "Julia", "RingRuby" ]))
	Then("SplitAfter keeps it with the left piece", @@( Q("JuliaRingRuby").SplitAfter("Ring") ), @@([ "JuliaRing", "Ruby" ]))
EndScenario()

Summary()
