# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #546.
#ERR Error (R14) : Calling Method without definition: lastnitemsqrt

load "../../stzBase.ring"

pr()

o1 = new stzString("12*45*78*c")
? o1.FindAll("*")
#--> [3, 6, 9]

? o1.NFirstOccurrences(2, :Of = "*") 
#--> [3, 6]

? o1.NFirstOccurrencesST(2, :Of = "*", :StartingAt = 5)
#--> [6, 9]

? o1.LastNOccurrencesST(2, :Of = "*", :StartingAt = 2)
#--> [6, 9]

pf()
# Executed in 0.05 second(s) in Ring 1.22
