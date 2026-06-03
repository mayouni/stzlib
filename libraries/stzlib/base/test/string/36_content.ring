# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #36.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("Ring---")

o1.RemoveThisTrailingChar("*")
? o1.Content()
#--> "Ring---"

o1.RemoveThisTrailingChar("-")
? o1.Content()
#--> "Ring"

pf()
# Executed in 0.05 second(s)
