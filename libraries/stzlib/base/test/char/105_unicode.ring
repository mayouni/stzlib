# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #105.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("ↈ")
? o1.Unicode() #--> 8584
? o1.IsRomanNumber() #--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23
