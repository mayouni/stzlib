# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #58.

load "../../stzBase.ring"

pr()

	RemoveFirst("two") 
	? Content() #--> [ "one", "three", "two", "four" ]
}

pf()
