# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #11.

load "../../stzBase.ring"


o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.RandomizeSection(5, 8)
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, "A", "C", "D", "B" ]
#--> [ 1, 2, 3, 4, "C", "A", "D", "B" ]
#--> [ 1, 2, 3, 4, "B", "A", "C", "D" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20
