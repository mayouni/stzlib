# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #216.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, single-repeated-bound family):
# BoundedByIBZ("&") / BoundedByIBZZ("&") RAISE "pacBounds must be [ open, close ]
# strings" -- the single-string bound is not widened to ["&","&"]. (And even with
# a pair, the Z/ZZ grouping is lost -- blocks 163/166/187.) Left in print form;
# NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.BoundedByIBZ("&") )
#--> expected [ [ "&^^^&", 4 ], [ "&vvv&", 12 ] ] (currently raises)

? @@( o1.BoundedByIBZZ("&") )
#--> expected [ [ "&^^^&", [4,8] ], [ "&vvv&", [12,16] ] ] (currently raises)

pf()
