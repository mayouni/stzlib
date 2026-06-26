load "../../stzBase.ring"
load "../_narrated.ring"

# The SubStringComesBefore/After/Between family. The POSITIONAL-arg forms work
# and are asserted here. Archive block #92.
#
# DEFECTS (deferred -- see _AUDIT_DEFECTS.md): the NAMED-PARAM forms
# (SubStringComesBefore(sub, :Position=n) / (sub, :SubString=s), and the After
# equivalents) return FALSE instead of dispatching to their positional twins;
# the fluent SubStringQ(...).ComesBeforeSubString() forms return FALSE; and
# ...BetweenSubStrings is order-dependent (block #91). Those are exercised as
# un-asserted NOTEs.

Scenario("Relative position of a substring (positional forms)")
	Given('"123♥♥678**123♥♥678" (first ♥♥ at 4, ** at 9)')
	o1 = new stzString("123♥♥678**123♥♥678")
	Then("♥♥ comes before position 6", o1.SubStringComesBeforePosition("♥♥", 6), TRUE)
	Then("♥♥ comes before the substring **", o1.SubStringComesBeforeSubString("♥♥", "**"), TRUE)
	Then("♥♥ comes after position 3", o1.SubStringComesAfterPosition("♥♥", 3), TRUE)
	Then("** comes after the substring ♥♥", o1.SubStringComesAfterSubString("**", "♥♥"), TRUE)
	Then("♥♥ comes between positions 3 and 6", o1.SubStringComesBetweenPositions("♥♥", 3, 6), TRUE)

	# Named-param + fluent forms currently return FALSE (not dispatched):
	? "  NOTE  ...ComesBefore(:Position=6) -> " + @@(o1.SubStringComesBefore("♥♥", :Position = 6)) + "  (named-param broken -- deferred)"
	? "  NOTE  ...ComesBefore(:SubString='**') -> " + @@(o1.SubStringComesBefore("♥♥", :SubString = "**")) + "  (named-param broken -- deferred)"
	? "  NOTE  SubStringQ('♥♥').InQ('--♥♥--**--').ComesBeforeSubString('**') -> " +
		@@(SubStringQ("♥♥").InQ("--♥♥--**--").ComesBeforeSubString("**")) + "  (fluent form broken -- deferred)"
EndScenario()

Summary()
