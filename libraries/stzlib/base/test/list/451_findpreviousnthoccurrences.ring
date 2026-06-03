# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #451.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	? FindPreviousNthOccurrences([2, 3], "A", 6)
	#--> [ 3, 5 ]

	RemovePreviousNthOccurrences([2, 3], :of = "A", :StartingAt = 6)
	? Content()
	#--> [ "A" , "B", "C", "D", "A" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? PreviousNthOccurrencesRemoved([2, 3], :of = "A", :StartingAt = 6)
	#--> [ "A" , "B", "C", "D", "A" ]
}

pf()
# Executed in 0.01 second(s).
