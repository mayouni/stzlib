# Narrative
# --------
# Category-based queries
#
# Extracted from stzadverbtest.ring, block #7.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

? len(GetAdverbRulesByCategory("domain"))	#--> 11
? len(GetAdverbRulesByCategory("morphology"))	#--> 12

pf()
# Executed in almost 0 second(s) in Ring 1.22
