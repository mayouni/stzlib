# Narrative
# --------
# WALKING WHILE
#
# Extracted from stzlisttest.ring, block #496.
#ERR Error (R3) : Calling Function without definition: walkwhilext

load "../../stzBase.ring"

pr()

StartProfiler()

StzListQ([ 1, 2, 3, "A", "B", 6, "C", "D", "E" ]) {

	? WalkWhile(' isNumber(@item) ')
	#--> [1, 2, 3]

	? WalkWhileXT(' isString(@item) ', :Backward, :WalkedItems)
	#--> ["E", "D", "C"]

	? WalkWhileXT(' isNumber(@item) ', :Default, :Default)
	#--> [1, 2, 3]
}

StopProfiler()
#--> Executed in 0.17 second(s)

pf()
