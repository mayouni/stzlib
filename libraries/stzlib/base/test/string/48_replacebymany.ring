# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #48.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): ReplaceByMany(sub, [r1,r2,r3])
# should replace each successive occurrence of `sub` with r1, r2, r3 (cycling),
# giving "ring php ruby ring python ring" -> "X php ruby XX python XXX". Instead
# the loop (stzString.ring ~2293) produces garbled output (" php ruby X python ":
# 1st and 3rd occurrences replaced by nothing, only the middle one survives).
# Left in print form pending the fix-pass; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("ring php ruby ring python ring")
o1.ReplaceByMany("ring", [ "X", "XX", "XXX" ])

? o1.Content() #--> expected "X php ruby XX python XXX" (currently broken)

pf()
