# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #6.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzHashList([
	:one   = "here",
	:two   = "and",
	:three = "not",
	:four  = "there"
])

# Finding some values

? @@( o1.FindValues([ "here", "and", "there" ]) )
#--> [ 1, 2, 4 ]

pf()
# Executed in 0.04 second(s)
