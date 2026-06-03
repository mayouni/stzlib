# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #607.

load "../../stzBase.ring"


StzStringQ("My name is #1, my age is #2, and my job is #3.") {
	? Marquers()
	#--> [ "#1", "#2", "#3" ]
}

StzStringQ("My name is #2, my age is #3, and my job is #1.") {
	? Marquers()
	#--> [ "#2", "#3", "#1" ]
}

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.28 second(s) in Ring 1.19
# Executed in 0.30 second(s) in Ring 1.18
