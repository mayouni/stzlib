# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #41.

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 2, 7, 18, 18, 10, 25, 4 ])

? @@( o1.Neighbors(10) )
#--> [ 7, 18 ]

? @@( o1.Neighbors(25) )
#--> [18, NULL ]

? @@( o1.Neighbors(2) )
#--> [ NULL, 4 ]

? @@( o1.Neighbors(88) )
#--> [ 25, NULL ]

? @@( o1.FarthestNighbors(10) ) # Misspelled form of FarthestNeighbors()
				# You can use the short form FNeighbors()
#--> [ 2, 25 ]

pf()
# Executed in 0.15 second(s)
