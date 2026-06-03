# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #638.

load "../../stzBase.ring"

pr()

StzStringQ("73964532041") {

	? SortedInAscending()
	#--> 01233445679

	? SortedInDescending()
	#--> 97654433210
}

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.20
