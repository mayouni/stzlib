# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #13.
#ERR Error (R14) : Calling Method without definition: sortupq

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 2, 7, 3, 10, 5, 4, 9, 1, 6, 8 ])

? o1.NSmallestNumbers(3) # Or Bottom3()
#--> [ 1, 2, 3 ]

? @@( o1.Bottom3Z() ) + NL # Or Bottom3AndTheirPositions()

# [ [ 1, 1 ], [ 2, 3 ], [ 3, 8 ] ]

? o1.NLargestNumbers(3)
#--> [ 8, 9, 10 ]

? @@( o1.Top3Z() )
# [ [ 8, 4 ], [ 9, 7 ], [ 10, 10 ] ]

pf()
# Executed in 0.04 second(s)
