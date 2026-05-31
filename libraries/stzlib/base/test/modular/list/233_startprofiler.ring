# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #233.

load "../../../stzBase.ring"


	? Q([ "♥", "♥", "♥" ]).IsMadeOfItem("♥")
	#--> TRUE

	? Q([ 12, 12, 12 ]).AllItemsAre(12)
	#--> TRUE

	? Q([ 1:3, 1:3, 1:3 ]).ContainsOnly(1:3)
	#--> TRUE

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.41 second(s) in Ring 1.17
