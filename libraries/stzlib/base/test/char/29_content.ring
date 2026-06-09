# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #29.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("0x61")
? o1.Content() #--> "a"
? o1.Name() #--> LATIN SMALL LETTER A

pf()
# Executed in 0.04 second(s) in Ring 1.23
