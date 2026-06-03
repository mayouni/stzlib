# Narrative
# --------
# o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
#
# Extracted from stzlistofstringstest.ring, block #115.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

? o1.NumberOfOccurrence("aabc") 		 #--> 1

pf()
