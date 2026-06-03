# Narrative
# --------
# /*--------- WALKING WHERE
#
# Extracted from stzlisttest.ring, block #494.
#ERR Error (R3) : Calling Function without definition: walkwhere

load "../../stzBase.ring"

pr()

StartProfiler()

StzListQ([ 1, 2, "A", "B", 5, "C", 7 ]) {

	? WalkWhere(' isNumber(@item) ')
	#--> [1, 2, 5, 7]

	? WalkWhereXT(' NOT isNumber(@item) ', :Backward, :Walkeditems)
	#--> ["C", "B", "A"]

	? WalkWhereXT(' isNumber(@item) ', :Default, :Default)
	#--> [1, 2, 5, 7]
}

StopProfiler()
#--> Executed in 0.20 second(s)

pf()
