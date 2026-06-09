# Narrative
# --------
# Creating duration from seconds
#
# Extracted from stzdurationtest.ring, block #1.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDuration = new stzDuration(3665)
? oDuration.Content() # Or ToString() or Duration()
#--> 1:01:05

pf()
# Executed in almost 0 second(s) in Ring 1.23
