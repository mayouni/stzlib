# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #919.

load "../../../stzBase.ring"


? IsSortedListOfPairsOfNumbers([ [4, 6], [10, 12], [16, 18] ])
#--> TRUE

? IsListOfPairsOfNumbersSortedUp([ [4, 6], [10, 12], [16, 18] ])
#--> TRUE

? IsListOfPairsOfNumbersSortedDown([ [16, 18], [10, 12], [4, 6] ])
#--> TRUE

pf()
