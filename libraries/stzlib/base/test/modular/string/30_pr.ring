# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #30.

load "../../../stzBase.ring"


o1 = new stzString("---Ring---")

o1.RemoveFirstCharXT()
? o1.Content()
#--> Ring---

? o1.RemoveLastCharXT()
? o1.Content()
#--> Ring

pf()
# Executed in 0.01 second(s).
