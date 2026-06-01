# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #621.

load "../../../stzBase.ring"


StzStringQ("My name is #1, my age is #2, and my job is #3.") {	
	? MarquersAreSorted()
	#--> TRUE

	? MarquersSortingOrder()
	#--> :Ascending
}

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.31 second(s) in Ring 1.18
