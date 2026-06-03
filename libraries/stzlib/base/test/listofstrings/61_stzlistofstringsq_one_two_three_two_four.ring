# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #61.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	RemoveMany([ "two", "four" ])
	# Same as RemoveManyStrings(), RemoveTheseStrings() and RemoveThese()
	? Content() #--> [ "one","three" ]
}

pf()
