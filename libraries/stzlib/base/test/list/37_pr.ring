# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #37.

load "../../stzBase.ring"


o1 = new stzList([ "♥", 2, "♥", "♥", 5, "♥" ])
o1.ReplaceByMany("♥", [ 1, 3, 4, 6 ])
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, 5, 6 ]

pf()
# Executed in 0.04 second(s)
