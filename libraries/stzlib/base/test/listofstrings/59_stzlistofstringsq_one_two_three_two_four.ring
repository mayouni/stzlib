# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #59.

load "../../stzBase.ring"

	

pr()

	RemoveNthOccurrence(2, "two")
	# Same as: RemoveNthOccurrenceOfString(2, "two")

	? Content()  #--> [ "one", "two", "three", "four" ]
}

pf()
