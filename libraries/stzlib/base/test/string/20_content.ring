# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #20.

load "../../stzBase.ring"

pr()

o1 = new stzString("---ring---")

o1.RemoveThisCharFromStartXT("*")
? o1.Content()
#--> "---ring---"

o1.RemoveThisCharFromStartXT("-")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromEndXT("*")
? o1.Content()
#--> "ring---"

o1.RemoveThisCharFromEndXT("-")
? o1.Content()
#--> "ring"

pf()
# Executed in 0.01 second(s).
