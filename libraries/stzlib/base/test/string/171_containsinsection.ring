# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #171.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Contains-in-section family"):
# ContainsInSection / ContainsBetweenPositions return FALSE on "^^♥^^" although
# the heart at position 3 is inside the given sections (2..4, 1..3). Same bug
# surfaced in blocks 103/104. Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsInSection("♥", 2, 4)        #--> expected TRUE (currently FALSE)
? Q("^^♥^^").ContainsBetweenPositions("♥", 2, 4) #--> expected TRUE (currently FALSE)
? Q("^^♥^^").ContainsInSection("♥", 1, 3)        #--> expected TRUE (currently FALSE)

pf()
