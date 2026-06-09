# Narrative
# --------
# Positive decimal number
#
# Extracted from stzdecimaltobinarytest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzDecimalToBinary("10.75")
? o1.ToBinaryForm()
#--> 0b1010.11

pf()
# Executed in 0.01 second(s) in Ring 1.23
