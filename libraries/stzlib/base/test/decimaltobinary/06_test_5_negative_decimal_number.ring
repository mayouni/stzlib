# Narrative
# --------
# Test 5: Negative decimal number
#
# Extracted from stzdecimaltobinarytest.ring, block #6.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o5 = new stzDecimalToBinary("-0.625")
? o5.ToBinaryForm()
#--> 0b-0.101

pf()
# Executed in 0.06 second(s) in Ring 1.23
