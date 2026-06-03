# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #45.

load "../../../stzBase.ring"


o1 = new stzListOfNumbers([ 1, 4, 6, 11, 18 ])

? @@( o1.FarthestNeighborsOf(5) ) # or FNeighborsOf(5)
#--> [ NULL, NULL ]

? @@( o1.FNeighbors(11) )
#--> [ 1, 18 ]

? @@( o1.FNeighbors(1) )
#--> [ NULL, 18 ]

? @@( o1.FNeighbors(18) )
#--> [ 1, NULL ]

pf()
# Executed in 0.10 second(s)
