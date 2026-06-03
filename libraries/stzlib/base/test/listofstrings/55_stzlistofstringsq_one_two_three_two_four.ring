# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #55.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	RemoveAll("two")

	? Content() #--> [ "one","three","four" ]
}

pf()
