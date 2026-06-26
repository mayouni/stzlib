load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsDuplicates() -- whether the string has any duplicated content. Archive
# block #160.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the archive's NumberOfDuplicates /
# FindDuplicates / Duplicates / DuplicatesZ #--> values here were copied from a
# different string ("RINGORIALAND", block 129) and don't match this input. They
# also hit the open Duplicates() chars-vs-substrings question. Only the boolean
# ContainsDuplicates() is asserted; the rest are NOTEs.

Scenario("Detecting that a string has duplicates")
	Given('"ring php ringoria"')
	o1 = new stzString("ring php ringoria")
	Then("it does contain duplicates", o1.ContainsDuplicates(), TRUE)
	? "  NOTE  FindDuplicates() -> " + @@(o1.FindDuplicates()) + "  (archive #--> was RINGORIALAND's -- deferred)"
	? "  NOTE  Duplicates()     -> " + @@(o1.Duplicates()) + "  (chars vs substrings -- block 129 -- deferred)"
EndScenario()

Summary()
