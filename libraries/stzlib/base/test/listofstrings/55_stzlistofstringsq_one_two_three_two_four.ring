# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #55.

load "../../stzBase.ring"

pr()

	RemoveAll("two")

	? Content() #--> [ "one","three","four" ]
}

pf()
