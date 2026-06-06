# Narrative
# --------
# LeadingChars() and LeadingCharsAsString()
#
# Extracted from stzStringTest.ring, block #33.

load "../../stzBase.ring"


pr()

o1 = new stzString("---Ring")
? o1.LeadingChars()
#--> [ "-", "-", "-" ]

? o1.LeadingCharsXT() # Or LeadingCharsAsString() or LeadingCharsAsSubString()
#--> "---"

o1 = new stzString("Ring---")
? o1.TrailingChars()
#--> [ "-", "-", "-" ]

? o1.TrailingCharsXT()
#--> "---"

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19
