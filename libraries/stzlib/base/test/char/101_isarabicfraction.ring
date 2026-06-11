# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #101.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("⅗")
? o1.IsArabicFraction() #--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.27 (Backed by stzEngine)
# Executed in 0.01 second(s) in Ring 1.23
