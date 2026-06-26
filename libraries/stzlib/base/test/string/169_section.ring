load "../../stzBase.ring"
load "../_narrated.ring"

# Section vs SectionXT with negative indices. Section auto-orders; SectionXT adds
# end-relative indexing. Archive block #169.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, block 46): SectionXT is documented to
# REVERSE when the resolved start > end, so SectionXT(-3, 3) should give "543";
# the impl returns "345" (no reversal). Left as an un-asserted NOTE.

Scenario("Sections forward and end-relative")
	Given('"1234567"')
	o1 = new stzString("1234567")
	Then("Section(3, 5) is '345'", o1.Section(3, 5), "345")
	Then("Section(5, 3) auto-orders to '345'", o1.Section(5, 3), "345")
	Then("SectionXT(3, -3) resolves -3 from the end -> '345'", o1.SectionXT(3, -3), "345")
	# Should reverse to "543"; impl returns "345":
	? "  NOTE  SectionXT(-3, 3) -> " + @@(o1.SectionXT(-3, 3)) + "  (should reverse to 543 -- deferred)"
EndScenario()

Summary()
