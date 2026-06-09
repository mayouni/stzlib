# Narrative
# --------
# o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
#
# Extracted from stzlistofstringstest.ring, block #115.
#ERR Error (R14) : Calling Method without definition: numberofoccurrence

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])

? o1.NumberOfOccurrence("aabc") 		 #--> 1

pf()
