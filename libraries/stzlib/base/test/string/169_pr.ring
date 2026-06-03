# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #169.

load "../../stzBase.ring"


o1 = new stzString("1234567")

? o1.Section(3, 5)
#--> 345

? o1.Section(5, 3)
#--> 345

? o1.SectionXT(3, -3)
#--> 345

? o1.SectionXT(-3, 3) + NL
#--> 543

pf()
# Executed in 0.01 second(s) in Ring 1.22
