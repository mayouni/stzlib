load "../../stzBase.ring"
load "../_narrated.ring"

# More ways to bound a Section: a position computed by FindNth, named :From/:To
# delimiters, and Range (an alias). Archive block #49.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): SectionXT(6, :UpToNChars = 11)
# should take 11 chars from position 6 ("Programming") but returns "" (the
# :UpToNChars named param is not handled). Left as an un-asserted NOTE.
# (The original's RandomPositionAfter line is non-deterministic, so it is dropped.)

Scenario("Bounding a section by computed positions and delimiters")
	Given('"Ring Programming Language"')
	o1 = new stzString("Ring Programming Language")
	Then("Section(6, FindNth(3,'g')) reaches the 3rd 'g'", o1.Section(6, o1.FindNth(3, "g")), "Programming")
	Then("Section(:From='L', :To='e') spans the delimiters", o1.Section(:From = "L", :To = "e"), "Language")
	Then("Range(6, 11) is a Section alias", o1.Range(6, 11), "Programming")
	# Should be "Programming" (11 chars from pos 6); the impl returns "":
	? "  NOTE  SectionXT(6, :UpToNChars=11) -> " + @@(o1.SectionXT(6, :UpToNChars = 11)) + "  (deferred)"
EndScenario()

Summary()
