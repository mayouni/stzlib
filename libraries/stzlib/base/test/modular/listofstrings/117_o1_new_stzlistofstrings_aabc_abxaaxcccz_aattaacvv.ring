# Narrative
# --------
# o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
#
# Extracted from stzlistofstringstest.ring, block #117.

load "../../../stzBase.ring"

? o1.NumberOfOccurrenceOfSubString("aa") #--> 4
? @@(o1.NumberOfOccurrenceOfSubStringXT("aa"))
#--> [ [ 1, 1 ], [ 2, 1 ], [ 3, 2 ] ]
