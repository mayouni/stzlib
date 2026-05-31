# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #450.

load "../../../stzBase.ring"


StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	? FindNextOccurrences(:Of = "A", :StartingAt = 3) #--> [ 5, 7 ]

	? FindPreviousOccurrences(:Of = "A", :StartingAt = 5) #--> [ 1, 3 ]

}

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20
