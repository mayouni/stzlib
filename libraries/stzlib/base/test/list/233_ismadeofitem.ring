# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #233.
#ERR Error (R14) : Calling Method without definition: ismadeofitem

load "../../stzBase.ring"

pr()


	? Q([ "♥", "♥", "♥" ]).IsMadeOfItem("♥")
	#--> TRUE

	? Q([ 12, 12, 12 ]).AllItemsAre(12)
	#--> TRUE

	? Q([ 12, 12, 12 ]).AllItemsAre(:Number)
	#--> TRUE

	? Q([ 12, 12, 12 ]).AllItemsAre(:Numbers) # In plural
	#--> TRUE

	? Q([ 12, 12, 12 ]).ContainsOnly(:Number)
	#--> TRUE

	? Q([ 12, 12, 12 ]).ContainsOnly(:Numbers) # In plural
	#--> TRUE

	? Q([ 1:3, 1:3, 1:3 ]).ContainsOnly(1:3)
	#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.41 second(s) in Ring 1.17
