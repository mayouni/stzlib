# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #60.

load "../../stzBase.ring"

pr()

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {

	RemoveStringsAtThesePositions([ 2, 4 ])
	? Content() #--> [ "one","three","four" ]
}

pf()
