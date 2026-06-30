load "../../stzBase.ring"
load "../_narrated.ring"

# Removing characters from the RIGHT of a string -- the mirror of block #24, read
# against "ring---". Archive block #25.
#   RightCharRemoved()        : drop exactly one rightmost char (unconditional)
#   CharRemovedFromRightXT(c) : drop the WHOLE trailing run of char c (no-op if absent)
#   CharTrimmedFromRight(c)   : alias of the XT form ("trim" = remove all trailing c)
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): CharRemovedFromRight(c) IGNORES its
# char argument and always drops the rightmost char like RightCharRemoved(), even
# when c is absent. It is therefore exercised below as a NOTE, not asserted.

Scenario("Removing chars from the right of a string")
	Given('"ring---"')
	o1 = new stzString("ring---")
	Then("RightCharRemoved() drops one trailing char", o1.RightCharRemoved(), "ring--")
	Then("...FromRightXT('*') is a no-op when '*' is absent", o1.CharRemovedFromRightXT("*"), "ring---")
	Then("...FromRightXT('-') strips the whole trailing run", o1.CharRemovedFromRightXT("-"), "ring")
	# CharTrimmedFromRight = trim-all; archive #--> "ring--" was the author's error.
	Then("CharTrimmedFromRight('-') trims every trailing '-'", o1.CharTrimmedFromRight("-"), "ring")

	Then("CharRemovedFromRight('*') is a no-op when '*' is not the trailing char",
		o1.CharRemovedFromRight("*"), "ring---")
	Then("CharRemovedFromRight('-') drops one matching trailing char",
		o1.CharRemovedFromRight("-"), "ring--")
EndScenario()

Summary()
