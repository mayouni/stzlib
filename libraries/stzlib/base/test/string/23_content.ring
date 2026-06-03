# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #23.
#ERR Error (R14) : Calling Method without definition: removethischarfromrightxt

load "../../stzBase.ring"

pr()

o1 = new stzString("ring---")

o1.RemoveThisCharFromRightXT("*")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromRightXT("-")
? o1.Content()
#--> "ring"

pf()
# Executed in 0.01 second(s).
