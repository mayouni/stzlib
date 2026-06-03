# Narrative
# --------
# */
#
# Extracted from stzbinarynumbertest.ring, block #5.

load "../../../stzBase.ring"

pr()

// Converting a binary number to a decimal form
o1 = new stzBinaryNumber("0b1010111")

? o1.ToDecimal()
#--> 87

? o1.ToOctal()
#--> 0o127

? o1.ToHex()
#--> 0x57

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.18
