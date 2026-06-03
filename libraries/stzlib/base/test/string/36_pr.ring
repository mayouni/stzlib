# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #36.

load "../../stzBase.ring"


o1 = new stzString("Ring---")

o1.RemoveThisTrailingChar("*")
? o1.Content()
#--> "Ring---"

o1.RemoveThisTrailingChar("-")
? o1.Content()
#--> "Ring"

pf()
# Executed in 0.05 second(s)
