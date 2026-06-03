# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #13.
#ERR Error (R14) : Calling Method without definition: randomizestrings

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "A", "B", "C", 6, 7, "D", "E", "F", "G" ])

o1.RandomizeStrings()
? @@( o1.Content() )
#--> [ 1, 2, "C", "A", "B", 6, 7, "D", "F", "G", "E" ]
#--> [ 1, 2, "A", "B", "C", 6, 7, "D", "E", "G", "F" ]
#--> [ 1, 2, "B", "A", "C", 6, 7, "F", "G", "E", "D" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20
