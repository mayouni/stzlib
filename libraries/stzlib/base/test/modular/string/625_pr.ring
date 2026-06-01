# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #625.

load "../../../stzBase.ring"


StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {

	? Marquers()
	#--> [ "#3", "#1", "#2" ]

	? @@( MarquersZ() ) + NL
	#--> [ [ "#3", 24 ], [ "#1", 42 ], [ "#2", 65 ] ]

	? @@( MarquersZZ() )
	#--> [ [ "#3", [ 24, 25 ] ], [ "#1", [ 42, 43 ] ], [ "#2", [ 65, 66 ] ] ]
}

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 1.36 second(s) in Ring 1.18
# Executed in 2.22 second(s) in Ring 1.17
