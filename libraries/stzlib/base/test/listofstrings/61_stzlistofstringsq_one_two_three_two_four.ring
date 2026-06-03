# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #61.

load "../../stzBase.ring"

pr()

	RemoveMany([ "two", "four" ])
	# Same as RemoveManyStrings(), RemoveTheseStrings() and RemoveThese()
	? Content() #--> [ "one","three" ]
}

pf()
