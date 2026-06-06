# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #22.

load "../../stzBase.ring"

pr()

o1 = new stzString("---ring")

o1.RemoveThisCharFromLeftXT("*")
? o1.Content()
#--> "---ring"

o1.RemoveThisCharFromLeftXT("-")
? o1.Content()
#--> ring

pf()
# Executed in 0.01 second(s).
