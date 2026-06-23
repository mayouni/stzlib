# Narrative
# --------
# ReplaceAtByManyXT: replace a SECTION of positions with a list of new
# values, one-for-one.
#
# Positions 3..5 (the "3","4","5") are replaced item-by-item with
# [ "-3", "-4", "-5" ], leaving the surrounding "_" sentinels in place. The
# section length and the replacement length line up, so it's a straight
# in-place swap of that run.
#
# Extracted from stzlisttest.ring, block #28.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "_", "_", "3", "4", "5", "6", "7", "_", "_" ])

o1.ReplaceAtByManyXT(3:5, [ "-3", "-4", "-5" ])
? @@( o1.Content() )
#--> [ "_", "_", "-3", "-4", "-5", "6", "7", "_", "_" ]

pf()
# Executed in almost 0 second(s)
