# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #103.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Contains-in-section family"):
# ContainsXT("♥", :InSection = [3,10]) and the :InSections form both return FALSE
# although section [3,10] of "123♥♥678♥♥1234♥♥789" clearly contains "♥" (at
# positions 4,5,9,10). The plain ContainsInSection forms (block #104) are broken
# the same way. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("123♥♥678♥♥1234♥♥789")

? o1.ContainsXT( "♥", :InSection = [ 3, 10 ] )                          #--> expected TRUE (currently FALSE)
? o1.ContainsXT( "♥", :InSections = [ [ 3, 10 ], [ 8, 12 ], [ 14, 19 ] ] ) #--> expected TRUE (currently FALSE)

pf()
