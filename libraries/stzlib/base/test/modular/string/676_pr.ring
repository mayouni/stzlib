# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #676.

load "../../../stzBase.ring"


o1 = new stzString("000122.12")

? o1.HasLeadingChars()
#--> TRUE

? o1.LeadingCharsXT()
#--> "000"

? o1.LeadingCharsRemoved()
#--> "122.12"

pf()
# Executed in 0.01 second(s).
