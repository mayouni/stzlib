# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #622.

load "../../stzBase.ring"


StzStringQ("My name is #3, my age is #2, and my job is #1.") {	
	? MarquersAreSorted()
	#--> TRUE

	? MarquersSortingOrder()
	#--> :Descending
}

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.31 second(s) in Ring 1.18
