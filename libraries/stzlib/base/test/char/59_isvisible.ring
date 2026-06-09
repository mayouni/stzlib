# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #59.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? StzCharQ("n").IsVisible() #--> TRUE

? StzCharQ(8207).IsInvisible() #--> TRUE
? StzCharQ(8207).Name() #--> RIGHT-TO-LEFT MARK

pf()
# Executed in 0.05 second(s) in Ring 1.23
