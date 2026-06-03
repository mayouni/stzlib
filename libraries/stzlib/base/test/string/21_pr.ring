# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #21.

load "../../stzBase.ring"


o1 = new stzString("ring---")

o1.RemoveThisCharFromEndXT("*")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromEndXT("-")
? o1.Content()
#--> "ring"

pf()
# Executed in 0.01 second(s).
