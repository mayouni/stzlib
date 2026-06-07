# Narrative
# --------
# Using ..Z() and ..ZZ() extensions
#
# Extracted from stzStringTest.ring, block #313.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindFirst("♥♥♥")
#--> 6

? o1.FindFirstAsSection("♥♥♥")
#--> [6, 8]

? o1.FirstZ("♥♥♥") # Or FindFirstZ()
#--> [ "♥♥♥", 6 ]

? o1.FirstZZ("♥♥♥") # Or FindfirstZZ()
#--> [ "♥♥♥", [6, 8] ]

pf()
# Executed in 0.02 second(s)
