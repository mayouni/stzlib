# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #121.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Bounds family"): BoundedBy with a
# SINGLE repeated bound pairs the occurrences non-overlappingly, so the middle
# region is dropped -- BoundedBy("aa") on "aa***aa**aa***aa" returns
# [ "***", "***" ] instead of the three consecutive gaps [ "***", "**", "***" ].
# (FindAnyBoundedByAsSections("aa") finds all three correctly -- block #124.)
# Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("aa***aa**aa***aa")
? @@( o1.BoundedBy("aa") ) #--> expected [ "***", "**", "***" ] (currently [ "***", "***" ])

pf()
