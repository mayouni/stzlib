# Narrative
# --------
# pr()
#
# Extracted from stzbinarynumbertest.ring, block #3.

load "../../stzBase.ring"

pr()

// Creating a binary number from a hex form
o1 = new stzBinaryNumber("")

o1.FromHex("0x127")
? o1.BinaryNumber()
#--> 0b100100111

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.04 second(s) on Ring 1.21
# Executed in 0.11 second(s) on Ring 1.20
