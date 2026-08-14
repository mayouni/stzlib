# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #61.

load "../../stzBase.ring"

pr()

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {

	RemoveMany([ "two", "four" ])
	# Same as RemoveManyStrings(), RemoveTheseStrings() and RemoveThese()
	? Content() #--> [ "one","three" ]
}

pf()
