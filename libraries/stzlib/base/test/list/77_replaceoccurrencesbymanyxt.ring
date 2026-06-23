# Narrative
# --------
# ReplaceOccurrencesByManyXT: replace items at the listed positions, CYCLING
# a shorter palette.
#
# Four positions (3,4,5,6) but only two replacements [ "#1", "#2" ]: the
# palette wraps -- #1,#2,#1,#2 -- so the four "*" placeholders become
# [ "A","B","#1","#2","#1","#2" ]. The "XT" suffix is the recycle dial
# (contrast block #76's 1-to-1 form).
#
# Extracted from stzlisttest.ring, block #77.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "*", "*", "*",  "*" ])

o1.ReplaceOccurrencesByManyXT([ 3, 4, 5, 6 ], [ "#1", "#2" ])

? @@( o1.Content() )
#--> [ "A", "B", "#1", "#2", "#1", "#2" ]

pf()
# Executed in 0.07 second(s)
