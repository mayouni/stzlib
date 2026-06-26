# Narrative
# --------
# BOUNDEDBY
#
# Extracted from stzStringTest.ring, block #213.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, single-repeated-bound family):
# BoundedBy("&") drops the in-between gaps -- on "...&^^^&...&vvv&...&..." it
# returns [ "^^^", "vvv" ] instead of [ "^^^", "...", "vvv", "..." ] (consecutive
# bounds paired non-overlappingly). And BoundedByIB("&") RAISES "pacBounds must be
# [ open, close ] strings" -- the single-string bound is not widened to ["&","&"].
# Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.BoundedBy("&") )
#--> expected [ "^^^", "...", "vvv", "..." ] (currently [ "^^^", "vvv" ])

? @@( o1.BoundedByIB("&") )
#--> expected [ "&^^^&", "&...&", "&vvv&", "&...&" ] (currently raises)

pf()
