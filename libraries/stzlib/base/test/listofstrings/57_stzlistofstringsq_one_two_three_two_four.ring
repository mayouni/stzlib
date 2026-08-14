# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #57.

load "../../stzBase.ring"

pr()

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {

	RemoveFirstString() #--> [ "two", "three", "two", "four" ]
	? Content()

	RemoveNthString(3) # or RemoveStringAtPosition(3)
	? Content() #--> [ "two", "three", "four" ]
}

pf()
