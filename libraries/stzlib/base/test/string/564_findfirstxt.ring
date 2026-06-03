# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #564.
#ERR Error (R14) : Calling Method without definition: findfirstxt

load "../../stzBase.ring"

pr()

o1 = new stzString("12*♥*56*♥*")

? o1.FindFirstXT("♥", :BoundedBy = [ "*", "*"])
#--> 4

? o1.FindFirstXT("♥", :BoundedBy = "*")
#--> 4

pf()
# Executed in 0.01 second(s) in Ring 1.22
