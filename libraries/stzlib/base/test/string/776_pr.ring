# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #776.

load "../../stzBase.ring"


o1 = new stzString("bbxeTuniseee")

? o1.RepeatedLeadingChars()
#--> [ "b", "b" ]

? o1.LeadingSubString()
#--> "bb"

? o1.HasRepeatedLeadingChars()
#--> TRUE

pf()
# Executed in 0.01 second(s).
