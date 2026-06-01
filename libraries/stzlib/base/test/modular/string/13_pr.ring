# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #13.

load "../../../stzBase.ring"


o1 = new stzString("me you all the others")
	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> TRUE
	
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> FALSE

o1 = new stzString("me and all the others")
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> TRUE

	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> TRUE

pf()
# Executed in 0.03 second(s)
