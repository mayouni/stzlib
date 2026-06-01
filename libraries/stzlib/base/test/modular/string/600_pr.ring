# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #600.

load "../../../stzBase.ring"


#           1          v    17            v       39
StzStringQ("ring is not the ring you ware but the ring you program with") {

	? @@( FindAll("ring") ) + NL
	#--> [ 1, 17, 39 ]

	? @@( FindNextOccurrences(:Of = "ring", :StartingAt = 12) ) + NL
	#--> [ 18, 40 ]

	? @@( FindPreviousOccurrences(:Of = "ring", :StartingAt = 32) )
	#--> [ 1, 17 ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.22
