# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #31.
#ERR Error (R14) : Calling Method without definition: removethisfirstcharxt

load "../../stzBase.ring"

pr()

o1 = new stzString("---Ring---")

o1.RemoveThisFirstCharXT("*")
? o1.Content()
#--> "---Ring---"

? o1.RemoveThisFirstCharXT("-")
? o1.Content()
#--> "Ring---"

o1.RemoveThisLastCharXT("*")
? o1.Content()
#--> "Ring---"

o1.RemoveThisLastCharXT("-")
? o1.Content()
#--> "Ring"

pf()
# Executed in 0.02 second(s)
