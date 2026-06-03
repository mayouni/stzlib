# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #57.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	RemoveFirstString() #--> [ "two", "three", "two", "four" ]
	? Content()

	RemoveNthString(3) # or RemoveStringAtPosition(3)
	? Content() #--> [ "two", "three", "four" ]
}

pf()
