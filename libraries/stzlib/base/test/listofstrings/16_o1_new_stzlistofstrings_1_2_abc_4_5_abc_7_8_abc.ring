# Narrative
# --------
# o1 = new stzListOfStrings([ "1", "2", "abc", "4", "5", "abc", "7", "8", "abc" ])
#
# Extracted from stzlistofstringstest.ring, block #16.

load "../../stzBase.ring"


? o1.FindAll("abc")
#--> [3, 6, 9]

#NOTE: the following functions work the same for stzString and
# stzList, because they are abstracted in stzObject


? o1.NFirstOccurrences(2, :Of = "abc") 
#--> [3, 6]

? o1.NFirstOccurrencesXT(2, :Of = "abc", :StartingAt = 1)
#--> [3, 6]

? o1.NLastOccurrences(2, :Of = "abc")
#--> [6, 9]

? o1.NLastOccurrencesXT(2, "abc", :StartingAt = 1)
#--> [6, 9]

? o1.NFirstOccurrencesXT(2, :Of = "abc", :StartingAt = 6)
#--> [6, 9]

? o1.LastNOccurrencesXT(2, :Of = "abc", :StartingAt = 10)
#--> [6, 9]
