# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #60.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	RemoveStringsAtThesePositions([ 2, 4 ])
	? Content() #--> [ "one","three","four" ]
}

pf()
