# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #666.

load "../../../stzBase.ring"


o1 = new stzString("125.450")
o1.RemoveNthChar(7)
? o1.Content()
#--> "125.45"

pf()
# Executed in 0.01 second(s).
