# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #351.
#ERR Error (R21) : Using operator with values of incorrect type

load "../../stzBase.ring"

pr()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindFirstST("♥♥♥", :StartingAt = 8)
#--> 22

? o1.FindLastST("♥♥♥", :Startingat = 8)
#--> 22

? o1.FindNthST(2, "♥♥♥", :StartingAt = 3)
#--> 22

pf()
# Executed in 0.02 second(s) in Ring 1.21
