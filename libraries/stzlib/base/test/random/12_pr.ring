# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #12.

load "../../stzBase.ring"


o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", 8, 9, 10, "D" ])

o1.RandomizeSections([ [1,4], [8,10] ])
? @@( o1.Content() )
#--> [ 1, 2, 4, 3, "A", "B", "C", 10, 8, 9, "D" ]
#--> [ 2, 1, 3, 4, "A", "B", "C", 9, 8, 10, "D" ]
#--> [ 2, 3, 4, 1, "A", "B", "C", 9, 8, 10, "D" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20
