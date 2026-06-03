# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #315.
#ERR Error (R14) : Calling Method without definition: findnthassection

load "../../stzBase.ring"

pr()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindNth(2, "♥♥♥")
#--> 22

? o1.FindNthAsSection(2, "♥♥♥")
#--> [22, 24]

? o1.NthZ(2, "♥♥♥") # Or o1.FindNthZ()
#--> [ "♥♥♥", 22 ]

? o1.FindNthZZ(2, "♥♥♥") # Or o1.NthZZ()
#--> [ "♥♥♥", [22, 24] ]

pf()
# Executed in 0.03 second(s)
