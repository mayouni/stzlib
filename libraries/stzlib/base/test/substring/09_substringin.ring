# Narrative
# --------
# */
#
# Extracted from stzsubstringTest.ring, block #9.
#ERR Error (R14) : Calling Method without definition: substringin

load "../../stzBase.ring"

pr()

o1 = new stzString("ring")

? o1.SubStringIn("I LOVE THE ring LANGUAGE!")
#--> ring

? @@( o1.SubStringIn("bla bla bla") )
#-->NULL

? o1.SubstringInQ("I LOVE THE ring LANGUAGE!").Uppercased()
#--> I LOVE THE RING LANGUAGE!

pf()
# Executed in 0.05 second(s)
