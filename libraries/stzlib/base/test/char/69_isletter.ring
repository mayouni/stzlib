# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #69.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("-")
? o1.IsLetter() #--> FALSE
? o1.Islowercase() #--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.23
