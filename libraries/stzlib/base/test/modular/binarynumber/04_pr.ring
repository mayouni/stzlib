# Narrative
# --------
# pr()
#
# Extracted from stzbinarynumbertest.ring, block #4.

load "../../../stzBase.ring"


// Creating a binary number from an octal form
o1 = new stzBinaryNumber("")

o1.FromOctal("0o127")
? o1.BinaryNumber()
#--> 0b1010111

pf()
# Executed in 0.04 second(s) in Ring 1.23
