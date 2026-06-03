# Narrative
# --------
#
# Extracted from stzListParserTest.ring, block #3.

load "../../stzBase.ring"

pr()

StzListParserQ("A":"L") {

	Parse( :From = 3, :To = 9, :Step = 3 )

	? ParsedPositions()	#--> [ 3,   6,   9   ]
	? ParsedItems()		#--> [ "C", "F", "I" ]

	? CurrentPosition()	#--> 3

	? NextNthPosition(2)	#--> 9
	? CurrentPosition()	#--> 9

}

pf()
# Executed in 0.04 second(s) in Ring 1.21
