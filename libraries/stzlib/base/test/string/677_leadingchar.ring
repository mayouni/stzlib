# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #677.

load "../../stzBase.ring"

pr()

o1 = new stzString("000122.12")
? o1.LeadingChar() #--> "0"

o1.RemoveThisLeadingChar("0")
? o1.Content()	#--> "122.12"

pf()
# Executed in 0.01 second(s).
