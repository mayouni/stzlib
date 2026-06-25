load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringsWF -- the substrings matching a Ring anonymous-function predicate.
# WF is the engine W-DSL's companion: when a predicate is too rich for the DSL
# (here NumberOfChars + ContainsCS), pass a func(s) called per candidate
# substring -- no eval(). Migrated from the retired SubStringsWXT.

Scenario("SubStringsWF finds substrings by a function predicate")
	Given('the string "..(h)^^(h)..^(h)(h)^.." with heart chars')
	Then("length-4 substrings containing a heart pair",
		@@( Q("..♥^^♥..^♥♥^..").SubStringsWF( func s { return Q(s).NumberOfChars() = 4 and Q(s).ContainsCS("♥♥", 1) } ) ),
		@@([ ".^♥♥", "^♥♥^", "♥♥^." ]))
EndScenario()

Summary()
