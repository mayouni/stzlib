# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #4.

load "../../stzBase.ring"


o1 = new stzListOfNumbers([ 1, 2, 3, 4, 5 ])
? @@( o1.Steps() )
#--> [ 1 ]

o1 = new stzListOfNumbers([ 1, 2, 5, 6, 9, 10 ])
? @@( o1.Steps() )
#--> [ 1, 3 ]

o1 = new stzListOfNumbers([ 4, 8, 2, 3, 7, 1, 2 ])
? @@( o1.Steps() )
#--> [ 4, -6, 1 ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
