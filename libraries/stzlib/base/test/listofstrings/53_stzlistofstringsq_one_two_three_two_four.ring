# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #53.

load "../../stzBase.ring"

pr()

	? FirstString()	#--> one
	? LastString()	#--> four
	
	? FindAll("two") #--> [ 2, 4 ]
	? FindFirst("two") #--> 2
	? FindLast("two") #--> 4
	? FindNthOccurrence(2, "two") #--> 4
}

pf()
