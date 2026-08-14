# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #58.

load "../../stzBase.ring"

pr()

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {

	RemoveFirst("two") 
	? Content() #--> [ "one", "three", "two", "four" ]
}

pf()
