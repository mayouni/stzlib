# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #44.

load "../../stzBase.ring"


o1 = new stzListOfNumbers([ 1, 4, 6, 11, 18 ])

? @@( o1.NeighborsOf(5) )
#--> [ NULL, NULL ]

? @@( o1.Neighbors(11) )
#--> [ 6, 18 ]

? @@( o1.Neighbors(1) )
#--> [ NULL, 4 ]

? @@( o1.Neighbors(22) )
#--> [ 18, NULL ]

pf()
# Executed in 0.10 second(s)
