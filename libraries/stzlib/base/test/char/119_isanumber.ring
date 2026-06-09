# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #119.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("6")
? o1.IsANumber() #--> TRUE
? o1.IsDigit()	 #--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23
