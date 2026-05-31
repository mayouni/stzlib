# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #26.

load "../../../stzBase.ring"


# There is no an empty char in Unicode
? Unicode("")	#--> ''
? StzCharQ("").Name()	#--> ERROR: Can't create char from empty string!

pf()
