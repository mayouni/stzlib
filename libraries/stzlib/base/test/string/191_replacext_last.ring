# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #191.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): ReplaceXT(:Last, sub, :With = new)
# is a NO-OP -- "_/♥\__/♥\__/♥♥_" is returned unchanged instead of having its
# last heart replaced. (Same as :First, block 190; the archive #--> was a
# mis-copied longer string.) Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("_/♥\__/♥\__/♥♥_")
o1.ReplaceXT(:Last, "♥", :With = "\")
? o1.Content()
#--> expected last heart replaced -> "_/♥\__/♥\__/♥\_" (currently unchanged)

pf()
