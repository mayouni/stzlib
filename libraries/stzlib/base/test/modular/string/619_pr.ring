# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #619.

load "../../../stzBase.ring"


Q("My name is #1, my age is #2, and my job is #3.") {	
	? MarquersAreSortedInAscending()
	#--> TRUE
}

StzStringQ("My name is #2, my age is #1, and my job is #3.") {	
	? MarquersAreSortedInAscending()
	#--> FALSE
}

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.54 second(s) in Ring 1.19
# Executed in 0.29 second(s) in Ring 1.18
# Executed in 0.45 second(s) in Ring 1.17
