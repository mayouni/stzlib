# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #405.

load "../../../stzBase.ring"


o1 = new stzString("123456789")

//? o1.Section(3, -3)
#!--> ERROR: Indexes out of range! n1 and n2 must be inside the string.

? o1.SectionXT(3, -3)
#--> "34567"

pf()
# Executed in 0.01 second(s) in Ring 1.21
