# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #21.
#ERR Error (R14) : Calling Method without definition: removethischarfromendxt

load "../../stzBase.ring"

pr()

o1 = new stzString("ring---")

o1.RemoveThisCharFromEndXT("*")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromEndXT("-")
? o1.Content()
#--> "ring"

pf()
# Executed in 0.01 second(s).
