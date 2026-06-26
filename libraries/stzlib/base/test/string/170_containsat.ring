load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsAt -- whether the substring sits at a given position. Archive block #170.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): ContainsAt works both positionally
# and with :Position, but the ContainsXT(sub, :AtPosition = n) spelling returns
# FALSE (the XT named-position forms are unparsed -- see blocks 173-175). Left as
# an un-asserted NOTE.

Scenario("Containment at a position")
	Given('"^^♥^^" (heart at position 3)')
	Then("ContainsAt(3, '♥') is TRUE", Q("^^♥^^").ContainsAt(3, "♥"), TRUE)
	Then("ContainsAt('♥', :Position=3) is TRUE", Q("^^♥^^").ContainsAt("♥", :Position = 3), TRUE)
	# The XT spelling is broken:
	? "  NOTE  ContainsXT('♥', :AtPosition=3) -> " + @@(Q("^^♥^^").ContainsXT("♥", :AtPosition = 3)) + "  (want TRUE -- deferred)"
EndScenario()

Summary()
