# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #18.

load "../../stzBase.ring"

pr()

o1 = new stzString("12345678")

? o1.Section(3, 5)
#--> 345

? o1.Section(5, 3)
#--> 345

pf()
# Executed in 0.01 second(s)
