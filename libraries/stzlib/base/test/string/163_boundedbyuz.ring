# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #163.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): BoundedByUZ / BoundedByUZZ should
# return UNIQUE bounded substrings grouped with their positions, e.g.
# [ [ "teeba", [5,27] ], [ "rined", [16] ] ], but the impl returns a flat list of
# positions ([ 5, 16, 27 ]) -- it loses the substring grouping entirely. Left in
# print form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzString("__<<teeba>>__<<rined>>__<<teeba>>")

? @@( o1.BoundedByUZ([ "<<", ">>" ]) )
#--> expected [ [ "teeba", [5,27] ], [ "rined", [16] ] ] (currently [ 5, 16, 27 ])

? @@( o1.BoundedByUZZ([ "<<", ">>" ]) )
#--> expected [ [ "teeba", [ [5,9],[27,31] ] ], [ "rined", [ [16,20] ] ] ]

pf()
