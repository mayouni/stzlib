# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #54.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	RemoveStringAtPosition(4)
	? @@( Content() ) #--> [ "one", "two", "three", "four" ]
}

pf()
