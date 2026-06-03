# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #10.
#ERR Error (R14) : Calling Method without definition: findnumbersassections

load "../../stzBase.ring"


o1 = new stzList([ "A", "B", 30, 40, 50, 60, "A", "B", "C" ])
o1.RandomizeNumbers()
? @@( o1.Content() )
#--> [ "A", "B", 30, 50, 40, 60, "A", "B", "C" ]
#--> [ "A", "B", 30, 40, 60, 50, "A", "B", "C" ]
#--> [ "A", "B", 30, 50, 60, 40, "A", "B", "C" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23

#--

pr()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.RandomizeStrings()
? o1.Content()
#--> [ 1, 2, 3, 4, "B", "C", "D", "A" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20

#--

pr()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])

o1.RandomizeSection(1, 4)
? @@( o1.Content() )
#--> [ 1, 4, 2, 3, "A", "B", "C", "D" ]
#--> [ 2, 1, 3, 4, "A", "B", "C", "D" ]
#--> [ 4, 3, 1, 2, "A", "B", "C", "D" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20
