# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #8.
#ERR Error (R14) : Calling Method without definition: containsonlyoneofthese

load "../../stzBase.ring"

pr()

o1 = new stzList([ "me", "you", "all", "the", "others" ])
	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> TRUE
	
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> FALSE

o1 = new stzlist([ "me", "and", "all", "the", "others" ])
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> TRUE

	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
