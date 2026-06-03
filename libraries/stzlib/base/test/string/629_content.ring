# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #629.

load "../../stzBase.ring"

pr()

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {

	SortMarquersInAscending()
	? Content() + NL
	#--> The first candidate is #1, the second is #2, while the third is #3!

	SortMarquersInDescending()
	? Content()
	#--> The first candidate is #3, the second is #2, while the third is #1!
}

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.53 second(s) in Ring 1.18
# Executed in 0.81 second(s) in Ring 1.17
