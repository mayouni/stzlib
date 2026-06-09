# Narrative
# --------
# o1 = new stzListOfStrings([ "ring php", "php", "ring php ring" ])
#
# Extracted from stzlistofstringstest.ring, block #116.
#ERR Error (R14) : Calling Method without definition: numberofoccurrenceofsubstring

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "ring php", "php", "ring php ring" ])

# How many occurrence are there of the substring "ring" in the list?
? o1.NumberOfOccurrenceOfSubString("ring") #--> 3

# Show these 3 in detail, string by string:
? @@( o1.NumberOfOccurrenceOfSubStringXT("ring") )
#--> [ [ 1, 1 ], [ 3, 2 ] ]

pf()
