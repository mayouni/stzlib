# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #34.

load "../../stzBase.ring"

pr()

o1 = new stzString("---Ring")

o1.RemoveLeadingChar() # Or RemoveAnyLeadingChar() or RemoveLeadingChars()
? o1.Content()
#--> Ring

o1 = new stzString("Ring---")
o1.RemoveTrailingChar() # Or RemoveAnyTrailingChar() or RemoveTrailingChars()
? o1.Content()
#--> Ring

pf()
# Executed in 0.01 second(s).
