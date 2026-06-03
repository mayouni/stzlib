# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #620.
#ERR Error (R3) : Calling Function without definition: marquersaresortedindescending

load "../../stzBase.ring"

pr()

StzStringQ("My name is #3, my age is #2, and my job is #1.") {	
	? MarquersAreSortedIndescending()
	#--> TRUE
}

StzStringQ("My name is #2, my age is #1, and my job is #3.") {	
	? MarquersAreSortedInDescending()
	#--> FALSE
}

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.29 second(s) in Ring 1.18
