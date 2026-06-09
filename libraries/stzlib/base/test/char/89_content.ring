# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #89.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar(8204)
? CharScript( o1.Content() ) # inherited

pf()
# Executed in almost 0 second(s) in Ring 1.23
