# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #43.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): BoundsOf / BoundsOfXT are broken
# (single flat pair / first-occurrence-only instead of per-occurrence bounds).
# Left in print form pending the bounds-family fix-pass; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
? o1.BoundsOf("Ring")
#--> [ ["<<<", ">>>"], [ "(((", ")))" ] ]

? o1.BoundsOfXT("Ring", :UpToNChars = 2) # Or BoundsOfUpToNChars()
#--> [ ["<<", ">>"], [ "((", "))" ] ]

pf()
# Executed in 0.03 second(s).
