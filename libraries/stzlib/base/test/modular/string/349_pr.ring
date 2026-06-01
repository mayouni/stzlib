# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #349.

load "../../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindOccurrences( [ 2, 3 ], :Of = "♥♥♥" ) ) # Or FindAllOccurrences()
#--> [ 8, 13 ]

? @@( o1.FindTheseOccurrences([ 2, 3], :Of = "♥♥♥") ) # Or FindOccurrencesXT()
#--> [ 8, 13 ]

? @@( o1.FindTheseOccurrencesZZ([ 2, 3], :Of = "♥♥♥") ) # Or FindOccurrencesAsSectionsXT
#--> [ [ 8, 10 ], [ 13, 15 ] ]

? @@( o1.FindTheseOccurrencesST([ 2, 3], :Of = "♥♥♥", :StartingAt = 2) ) # Or FindOccurrencesXTS()
#--> [ 3, 8, 13 ]

? @@( o1.FindTheseOccurrencesSTZZ([ 2, 3], :Of = "♥♥♥", :StartingAt = 2) ) # Or FindOccurrencesXTS()
#--> [ [ 3, 5 ], [ 8, 10 ], [ 13, 15 ] ]

pf()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.18
