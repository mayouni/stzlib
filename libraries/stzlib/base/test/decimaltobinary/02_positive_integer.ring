# Narrative
# --------
# Positive integer
#
# Extracted from stzdecimaltobinarytest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzDecimalToBinary("42")
? o1.ToBinaryForm()
#--> 0b101010

pf()
# Executed in 0.01 second(s) in Ring 1.23
