# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #102.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("万")
? o1.IsMandarinNumber() #--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23
