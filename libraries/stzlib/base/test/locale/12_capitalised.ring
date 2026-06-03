# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #12.
#ERR Error (R14) : Calling Method without definition: capitalised

load "../../stzBase.ring"

pr()

o1 = new stzString("chinese yuan")
? o1.Capitalised()
#--> Chinese Yuan

pf()
# Executed in almost 0 second(s) in Ring 1.23
