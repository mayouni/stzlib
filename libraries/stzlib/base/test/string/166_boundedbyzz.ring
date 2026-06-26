# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #166.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): BoundedByZZ / BoundedByUZZ should
# return each bounded substring grouped with its position span, e.g.
# [ [ "hi!", [3,5] ], [ "--♥♥♥--♥♥♥--", [12,23] ], [ "hi!", [30,32] ] ], but the
# impl returns positions ONLY ([ [3,5], [12,23], [30,32] ]) -- the substring is
# lost (same as BoundedByUZ, block 163). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("<<hi!>>..<<--♥♥♥--♥♥♥-->>..<<hi!>>")
? @@NL( o1.BoundedByZZ([ "<<", ">>" ]) ) + NL
#--> expected each substring paired with its [from,to] span (currently positions only)

? @@NL( o1.BoundedByUZZ([ "<<", ">>" ]) )
#--> expected unique substrings grouped with their spans

pf()
