# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #628.
#ERR Error (R3) : Calling Function without definition: marquerssorteduz

load "../../stzBase.ring"

pr()

StzStringQ("My name is #1, my age is #3, and my job is #2. Again: my name is #1!") {	

	? @@( MarquersSortedUZ() ) + NL
	#--> [ [ "#1", [ 12, 66 ] ], [ "#2", [ 44 ] ], [ "#3", [ 26 ] ] ]

	? @@( MarquersSortedUZZ() )
	#--> [
	# 	[ "#1", [ [ 12, 13 ], [ 66, 67 ] ] ],
	# 	[ "#2", [ [ 44, 45 ] ] ],
	# 	[ "#3", [ [ 26, 27 ] ] ]
	# ]
}

pf()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.39 second(s) in Ring 1.18
# Executed in 0.57 second(s) in Ring 1.17
