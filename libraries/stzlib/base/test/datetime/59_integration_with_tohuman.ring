# Narrative
# --------
# Integration with ToHuman()
#
# Extracted from stzdatetimetest.ring, block #59.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oHuman = StzDateTimeQ("2024-03-15 14:30:00")

? oHuman.ToHuman()
#--> Friday March 15, 2024 at 2:30 PM

pf()
# Executed in almost 0 second(s) in Ring 1.24
