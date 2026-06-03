# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #61.
#ERR Error (R14) : Calling Method without definition: firstnitemsqrt

load "../../stzBase.ring"

pr()

o1 = new stzListOfLists([
	1:2, 1:3, [9,9,9], 1:4, 1:5, [9,9,9], 1:7, 1:8, [9,9,9]
])


? o1.FindAll([9,9,9])
#--> [3, 6, 9]

#NOTE: the following functions work the same for stzString, 
# stzList, and stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = [9,9,9]) 
#--> [3, 6]

? o1.NFirstOccurrencesXT(2, :Of = [9,9,9], :StartingAt = 1)
#--> [3, 6]

? o1.NLastOccurrences(2, :Of = [9,9,9])
#--> [6, 9]

? o1.NLastOccurrencesXT(2, [9,9,9], :StartingAt = 1)
#--> [6, 9]

? o1.NFirstOccurrencesXT(2, :Of = [9,9,9], :StartingAt = 6)
#--> [6, 9]

? @@(o1.LastNOccurrencesXT(1, :Of = [9,9,9], :StartingAt = 9))
#--> [9]

pf()
# Executed in 0.15 second(s)
