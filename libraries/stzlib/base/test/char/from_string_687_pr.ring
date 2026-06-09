# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #687.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? StzCharQ("é").Script()
#--> latin

? StzCharQ("ن").Script()
#--> arabic

pf()
# Executed in 0.01 second(s).
