# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #856.

load "../../stzBase.ring"


o1 = new stzString("number 12500 number 18200")
? o1.OnlyNumbers()
#--> "1250018200"

pf()
# Executed in 0.06 second(s).
