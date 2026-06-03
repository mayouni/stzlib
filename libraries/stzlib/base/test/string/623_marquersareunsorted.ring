# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #623.

load "../../stzBase.ring"

pr()

StzStringQ("My name is #1, my age is #3, and my job is #2.") {	

	? MarquersAreUnsorted()
	#--> TRUE

	? MarquersSortingOrder()
	#--> :Unsorted

}

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.31 second(s) in Ring 1.18
# Executed in 0.53 second(s) in Ring 1.17
