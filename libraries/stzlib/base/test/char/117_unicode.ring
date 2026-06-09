# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #117.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("㊱")
? o1.Unicode() #--> 12977
? o1.NumberOfBytes() #--> 3

pf()
# Executed in almost 0 second(s) in Ring 1.23
