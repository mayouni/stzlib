# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #104.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Contains-in-section family"):
# ContainsInSection("♥", 3, 10) and ContainsInSections(...) both return FALSE
# although the sections clearly contain "♥". (Same bug surfaced via the XT form
# in block #103.) Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("123♥♥678♥♥1234♥♥789")

? o1.ContainsInSection("♥", 3, 10)                          #--> expected TRUE (currently FALSE)
? o1.ContainsInSections("♥", [ [3,10], [8,12], [14,19] ])   #--> expected TRUE (currently FALSE)

pf()
