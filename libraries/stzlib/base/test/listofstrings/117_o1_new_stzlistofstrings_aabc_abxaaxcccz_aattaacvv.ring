# Narrative
# --------
# o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
#
# Extracted from stzlistofstringstest.ring, block #117.
#ERR Error (R14) : Calling Method without definition: numberofoccurrenceofsubstring

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])

? o1.NumberOfOccurrenceOfSubString("aa") #--> 4
? @@(o1.NumberOfOccurrenceOfSubStringXT("aa"))
#--> [ [ 1, 1 ], [ 2, 1 ], [ 3, 2 ] ]

pf()
