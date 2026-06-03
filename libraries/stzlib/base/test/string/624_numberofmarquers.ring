# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #624.
#ERR Error (R3) : Calling Function without definition: numberofmarquers

load "../../stzBase.ring"

pr()

CheckParamsOff()

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {
	
	? NumberOfMarquers() + NL
	#--> 3
	? MarquersPositions() # Or FindMarquers()
	#--> [ 24, 42, 65 ]
	
	? FindNextNthMarquer(2, 14) + NL
	#--> 42
	
	? MarquersPositionsSortedInAscending()
	#--> [ 24, 42, 65 ]
}

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.69 second(s) in Ring 1.18
