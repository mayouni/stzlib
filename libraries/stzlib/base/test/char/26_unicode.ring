# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #26.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# There is no an empty char in Unicode
? Unicode("")	#--> ''
? StzCharQ("").Name()	#--> ERROR: Can't create char from empty string!

pf()
