load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringComesBetween(sub, A, B) -- is `sub` positioned between substrings A
# and B? Archive block #91.
#
# SEMANTICS TO CONFIRM (deferred -- see _AUDIT_DEFECTS.md): the impl is
# order-DEPENDENT (A must come before B), but the archive expected it to be
# order-INDEPENDENT (TRUE for both bound orders). The reversed-order call is left
# as an un-asserted NOTE.

Scenario("A substring positioned between two bounds")
	Given('"---♥♥...**---" (hearts, then "...", then "**")')
	o1 = new stzString("---♥♥...**---")
	Then("'...' comes between ♥♥ and ** (in order)", o1.SubStringComesBetween("...", "♥♥", "**"), TRUE)
	Then("and order-independently between ** and ♥♥", o1.SubStringComesBetween("...", "**", "♥♥"), TRUE)
EndScenario()

Summary()
