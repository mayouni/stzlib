# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #286.

load "../../stzBase.ring"


o1 = new stzListOfNumbers([ 3, 4, 5, 7, 8, 9, 11, 14, 15, 20 ])
? @@( o1.ContigToSections() )
#--> [ [ 3, 5 ], [ 7, 9 ], [ 11, 11 ], [ 14, 15 ], [ 20, 20 ] ]

pf()
# Executed in 0.02 second(s).
