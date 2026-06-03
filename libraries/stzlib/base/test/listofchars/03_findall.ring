# Narrative
# --------
# pr()
#
# Extracted from stzlistofcharstest.ring, block #3.

load "../../stzBase.ring"

pr()

o1 = new stzListOfChars([ "1", "2", "♥", "4", "5", "♥", "7", "8", "♥" ])

? o1.FindAll("♥")
#--> [3, 6, 9]

#NOTE: the following functions work the same for stzString, 
# stzList, and stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = "♥") 
#--> [3, 6]

? o1.NFirstOccurrencesST(2, :Of = "♥", :StartingAt = 1)
#--> [3, 6]

? o1.NLastOccurrences(2, :Of = "♥")
#--> [6, 9]

? o1.NLastOccurrencesST(2, "♥", :StartingAt = 1)
#--> [6, 9]

? o1.NFirstOccurrencesST(2, :Of = "♥", :StartingAt = 6)
#--> [6, 9]

? o1.LastNOccurrencesST(1, :Of = "♥", :StartingAt = 9)
#--> [ 9 ]

pf()
# Executed in 0.10 second(s).
