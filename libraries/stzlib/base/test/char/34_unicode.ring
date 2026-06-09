# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #34.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? Unicode("ↈ") #--> 8584
? StzCharQ("ↈ").Name()	#--> ROMAN NUMERAL ONE HUNDRED THOUSAND

pf()
# Executed in 0.04 second(s) in Ring 1.23
