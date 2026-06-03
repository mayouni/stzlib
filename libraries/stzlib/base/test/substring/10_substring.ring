# Narrative
# --------
# pr()
#
# Extracted from stzsubstringTest.ring, block #10.
#ERR Error (R14) : Calling Method without definition: substring

load "../../stzBase.ring"

pr()

o1 = new stzString("I LOVE THE ring LANGUAGE!")

? o1.SubString("ring")
#--> ring

? @@( o1.SubString("python") )
#-->NULL

? o1.SubStringQ("ring").Uppercased()
#--> I LOVE THE RING LANGUAGE!

pf()
