# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #618.

load "../../stzBase.ring"


CheckParamsOff() # Potential gain of performance

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? @@( FindMarquersAsSections() ) + NL
	#--> [ [ 12, 13 ], [ 26, 27 ], [ 44, 45 ], [ 66, 67 ] ]

	? @@( MarquersZZ() ) + NL
	#--> [
	# 	[ "#1", [ 12, 13 ] ],
	# 	[ "#2", [ 26, 27 ] ],
	# 	[ "#3", [ 44, 45 ] ],
	# 	[ "#1", [ 66, 67 ] ]
	# ]

	? @@( MarquersUZZ() ) # Or UniqueMarquersAndTheirSections()
	#--> [
	# 	[ "#1", [ [ 12, 13 ], [ 66, 67 ] ] ],
	# 	[ "#2", [ [ 26, 27 ] ] ],
	# 	[ "#3", [ [ 44, 45 ] ] ]
	# ]

}

pf()

# Executed in 0.05 second(s) in Ring 1.21 WithCheckParamsOff()
# Executed in 0.05 second(s) in Ring 1.21 WithCheckParams()

# Executed in 1.67 second(s) in Ring 1.19 with CheckParamsOff()
# Executed in 2.58 second(s) in Ring 1.19 without CheckParamsOff()

# Executed in 4.65 second(s) in Ring 1.18
# Executed in 7.74 second(s) in Ring 1.17
