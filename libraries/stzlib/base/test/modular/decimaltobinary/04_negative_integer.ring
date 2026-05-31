# Narrative
# --------
# Negative integer
#
# Extracted from stzdecimaltobinarytest.ring, block #4.

load "../../../stzBase.ring"


pr()

o1 = new stzDecimalToBinary("-7")
? o1.ToBinaryForm()
#--> 0b-111

pf()
# Executed in 0.02 second(s) in Ring 1.23
