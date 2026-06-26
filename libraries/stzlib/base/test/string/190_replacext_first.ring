# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #190.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): ReplaceXT(:First, sub, :With = new)
# is a NO-OP -- "_♥♥\__/♥\__/♥\_" is returned unchanged instead of having its
# first heart replaced. (ReplaceXT(:Nth=n) works -- block 189; only :First/:Last
# are broken. The archive #--> here was also a mis-copied longer string.) Left in
# print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("_♥♥\__/♥\__/♥\_")
o1.ReplaceXT(:First, "♥", :With = "/")
? o1.Content()
#--> expected first heart replaced -> "_/♥\__/♥\__/♥\_" (currently unchanged)

pf()
