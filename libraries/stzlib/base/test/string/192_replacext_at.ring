# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #192.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): ReplaceXT(sub, :At = 2, :With = new)
# treats 2 as an OCCURRENCE INDEX, not a character POSITION -- on "~♥/♥\~~" it
# replaces the 2nd heart (position 4) giving "~♥/~\~~" instead of replacing the
# heart at position 2 ("~~/♥\~~"). Same bug as :AtPosition (block 71). The plural
# :AtPositions form (block 193) correctly uses positions. Left in print form;
# NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("~♥/♥\~~")
o1.ReplaceXT("♥", :At = 2, :With = "~")
? o1.Content()
#--> expected "~~/♥\~~" (currently "~♥/~\~~" -- :At treated as occurrence index)

pf()
