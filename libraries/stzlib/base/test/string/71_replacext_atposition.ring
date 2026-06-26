# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #71.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): ReplaceXT(sub, :AtPosition = n, :By
# = new) treats n as an OCCURRENCE INDEX (routes to ReplaceNth, stzString.ring
# ~2790) instead of a character POSITION, so ReplaceXT("ring", :AtPosition = 6)
# is a no-op (there is no 6th "ring"). The plural :AtPositions form (block #72)
# and the plain ReplaceAt(6, ...) form (block #70) both work. Left in print form;
# NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("ruby ring php")
o1.ReplaceXT("ring", :AtPosition = 6, :By = "♥♥♥")
? o1.Content() #--> expected "ruby ♥♥♥ php" (currently a no-op: "ruby ring php")

pf()
