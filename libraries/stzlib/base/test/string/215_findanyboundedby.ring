# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #215.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, single-repeated-bound family):
# with a single "&" bound, FindAnyBoundedBy("&") returns SUBSTRINGS [ "^^^",
# "vvv" ] (wrong type AND drops the middle) instead of the positions
# [ 5, 9, 13, 17 ]; and FindAnyBoundedByIB / ...ZZ / ...IBZZ RAISE "pacBounds
# must be [ open, close ] strings". The pair-bound forms work elsewhere. Left in
# print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.FindAnyBoundedBy("&") )       #--> expected [ 5, 9, 13, 17 ] (currently substrings)
? @@( o1.FindAnyBoundedByIB("&") )     #--> expected [ 4, 8, 12, 16 ] (currently raises)
? @@( o1.FindAnyBoundedByZZ("&") )     #--> expected [ [5,7],[9,11],[13,15],[17,19] ]
? @@( o1.BoundedBy("&") )              #--> expected [ "^^^", "...", "vvv", "..." ]

pf()
