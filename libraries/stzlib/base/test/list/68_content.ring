# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #68.
#ERR exit 1: Line 79 Bad parameters value, error in length!

load "../../stzBase.ring"

pr()

o1 = new stzString("♥♥♥123♥♥♥")
o1.TrimChar("♥")
? o1.Content()
#--> "123"

pf()
# Executed in 0.03 second(s)
