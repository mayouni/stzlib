# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #279.

load "../../stzBase.ring"


o1 = new stzString("999999999999")
o1.UpdateWith("999 999 999.999")
? o1.Content()

pf()
# Executed in 0.01 second(s).
