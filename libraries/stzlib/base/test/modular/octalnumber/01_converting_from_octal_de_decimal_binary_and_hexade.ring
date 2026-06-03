# Narrative
# --------
# Converting from octal de decimal, binary, and hexadecimal
#
# Extracted from stzoctalnumbertest.ring, block #1.

load "../../../stzBase.ring"


pr()

o1 = new stzOctalNumber("o2007")

? o1.OctalNumber()
#--> o2007

? o1.ToDecimal()
#--> 1031

? o1.ToBinary()
#--> 0b10000000111

? o1.ToHex()
#--> 0x407

pf()
# Executed in 0.05 second(s).
