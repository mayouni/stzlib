# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #142.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Extend family"): ExtendXT(
# :ToPosition = 5, :With = :CharsRepeated) treats the :CharsRepeated SYMBOL as a
# literal string -- it appends "charsrepeated" repeatedly ("ABCcharsrepeated-
# charsrepeated") instead of repeating the string's own chars to give "ABCAB".
# Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :With = :CharsRepeated )
o1.Show()
#--> expected "ABCAB" (currently "ABCcharsrepeatedcharsrepeated")

pf()
