# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #599.
#ERR Error (R3) : Calling Function without definition: nextnthoccurrence

load "../../stzBase.ring"

pr()

StzStringQ("ring is not the ring you ware but the ring you program with") {

	? NextNthOccurrence(1, :of = "ring", :startingat = 1)
	#--> 2

	? NextNthOccurrence(2, :of = "ring", :startingat = 17)
	#--> 40
}

pf()
# Executed in 0.01 second(s) in Ring 1.22
