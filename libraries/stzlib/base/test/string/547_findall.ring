# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #547.

load "../../stzBase.ring"

pr()

o1 = new stzString("12abc67abc12abc")

? o1.FindAll("abc")
#--> [3, 8, 13]

#NOTE: the following functions work the same for stzString and
# stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = "abc") 
#--> [3, 8]

? o1.NFirstOccurrencesST(2, :Of = "abc", :StartingAt = 1)
#--> [3, 8]

? o1.NLastOccurrences(2, :Of = "abc")
#--> [8, 13]

? o1.NLastOccurrencesST(2, "abc", :StartingAt = 1)
#--> [8, 13]

? o1.NFirstOccurrencesST(2, :Of = "abc", :StartingAt = 5)
#--> [8, 13]

? o1.LastNOccurrencesST(2, :Of = "abc", :StartingAt = 3)
#--> [8, 13]

pf()
# Executed in 0.07 second(s) in Ring 1.22
