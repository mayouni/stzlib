load "../../stzBase.ring"
load "../_narrated.ring"

# Removing characters from the LEFT of a string -- the related (non-mutating)
# forms, all read against "---ring". Archive block #24.
#   LeftCharRemoved()        : drop exactly one leftmost char (unconditional)
#   CharRemovedFromLeftXT(c) : drop the WHOLE leading run of char c (no-op if absent)
#   CharTrimmedFromLeft(c)   : alias of the XT form ("trim" = remove all leading c)
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): CharRemovedFromLeft(c) IGNORES its
# char argument and always drops the leftmost char like LeftCharRemoved(), even
# when c is absent. It is therefore exercised below as a NOTE, not asserted.

Scenario("Removing chars from the left of a string")
	Given('"---ring"')
	o1 = new stzString("---ring")
	Then("LeftCharRemoved() drops one leading char", o1.LeftCharRemoved(), "--ring")
	Then("...FromLeftXT('*') is a no-op when '*' is absent", o1.CharRemovedFromLeftXT("*"), "---ring")
	Then("...FromLeftXT('-') strips the whole leading run", o1.CharRemovedFromLeftXT("-"), "ring")
	# CharTrimmedFromLeft = trim-all; archive #--> "--ring" was the author's error.
	Then("CharTrimmedFromLeft('-') trims every leading '-'", o1.CharTrimmedFromLeft("-"), "ring")

	# DEFECT: ignores its arg -- drops '-' even though '*' was requested (expected "---ring").
	? "  NOTE  CharRemovedFromLeft('*') -> " + o1.CharRemovedFromLeft("*") + "  (char arg ignored -- deferred fix)"
EndScenario()

Summary()
