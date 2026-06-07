# Narrative
# --------
# pr()
#
# Extracted from stzbinarynumbertest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

// Creating a binary number from a decimal form

o1 = new stzBinaryNumber("")

o1.FromDecimal(127)
? o1.BinaryNumber()
#--> 0b1111111

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.03 second(s) on Ring 1.21
# Executed in 0.07 second(s) on Ring 1.20
