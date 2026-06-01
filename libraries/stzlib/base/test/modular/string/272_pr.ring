# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #272.

load "../../../stzBase.ring"


o1 = new stzListOfNumbers([ 3, 7, 12, 15 ])

? @@( o1.ToSections() ) # Or Sectioned()
#--> [ [ 1, 3 ], [ 4, 7 ], [ 8, 12 ], [ 13, 15 ] ]

pf()
#--> Executed in 0.02 second(s).
