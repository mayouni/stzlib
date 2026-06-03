# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #58.

load "../../../stzBase.ring"

	RemoveFirst("two") 
	? Content() #--> [ "one", "three", "two", "four" ]
}
