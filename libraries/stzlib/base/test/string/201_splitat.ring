# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #201.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): stzList.SplitAt("*") raises
# "Error (R41): Invalid numeric string" (stzList.ring ~5096) -- it appears to
# treat the separator value as a numeric index. SplitAtZZ likely shares the bug.
# (AntiPositions / AntiPositionsZZ are the related working ops.) Left in print
# form; NOT asserted.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3 , "*", 5, 6, "*", 8 ])

? @@( o1.SplitAt("*") )   # raises R41: Invalid numeric string
#--> expected [ [ 1, 2, 3 ], [ 5, 6 ], [ 8 ] ]

? @@( o1.AntiPositions([ 4, 7 ]) )
#--> expected [ 1, 2, 3, 5, 6, 8 ]

pf()
