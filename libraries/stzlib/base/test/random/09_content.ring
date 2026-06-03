# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #9.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.Randomize()
? @@( o1.Content() )
#--> [ 1, "A", 4, 3, "D", "C", "B", 2 ]
#--> [ 1, "B", 2, "A", "C", 4, "D", 3 ]
#--> [ "B", "D", 2, 3, 4, 1, "A", "C" ]

pf()
