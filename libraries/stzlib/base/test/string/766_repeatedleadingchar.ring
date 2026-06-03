# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #766.
#ERR Error (R14) : Calling Method without definition: repeatedleadingchar

load "../../stzBase.ring"

pr()

o1 = new stzString("eeeTUNIS")

? o1.RepeatedLeadingChar()
#--> "e"

? o1.RepeatedLeadingChars()
#--> [ "e", "e", "e" ]

? o1.LeadingSubString()
#--> "eee"

pf()
# Executed in 0.01 second(s).
