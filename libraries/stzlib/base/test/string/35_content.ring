# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #35.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("---Ring")

o1.RemoveThisLeadingChar("*")
? o1.Content()
#--> "---Ring"

o1.RemoveThisLeadingChar("-")
? o1.Content()
#--> "Ring"

pf()
# Executed in 0.02 second(s)
