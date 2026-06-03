# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #312.
#ERR Error (R14) : Calling Method without definition: tosetq

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 1, 4, 6, 11, 18 ])

? o1.NeighborsOf(1)
#--> [ 4 ]

? o1.NeighborsOf(5)
#--> [ 4, 6 ]

? o1.NeighborsOf(6)
#--> [4, 11]

? o1.NeighborsOf(18)
#--> [ 11 ]

? o1.NeighborsOf(-2)
#--> [ 1]

? o1.NeighborsOf(22)
#--> [ 18 ]

StopProfiler()

pf()
# Executed in 0.02 second(s)
