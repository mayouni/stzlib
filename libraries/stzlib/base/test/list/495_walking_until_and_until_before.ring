# Narrative
# --------
# WALKING UNTIL (AND UNTIL BEFORE)
#
# Extracted from stzlisttest.ring, block #495.
#ERR exit 1: 1

load "../../stzBase.ring"

pr()

StartProfiler()

StzListQ([ 1, 2, 3, "A", "B", 6, "C", "D", "E" ]) {

	? WalkUntil(' isString(@item) ')
	#--> [1, 2, 3, 4]

	? WalkUntil(:Before = ' isString(@item) ')
	#--> [1, 2, 3]

	? WalkUntilXT(:Before = ' isNumber(@item) ', :Backward, :WalkedItems)
	#--> ["E", "D", "C"]

	? WalkUntilXT(' isString(@item) ', :Default, :Default)
	#--> [1, 2, 3, 4]
}

StopProfiler()
#--> Executed in 0.24 second(s)

pf()
