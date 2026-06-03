# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #54.

load "../../stzBase.ring"

pr()

	RemoveStringAtPosition(4)
	? @@( Content() ) #--> [ "one", "two", "three", "four" ]
}

pf()
