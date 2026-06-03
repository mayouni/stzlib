# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #627.

load "../../stzBase.ring"


StzStringQ("My name is #1, my age is #3, and my job is #2. Again: my name is #1!") {	

	? @@( MarquersSortedZ() ) + NL
	#--> [ [ "#1", 12 ], [ "#1", 26 ], [ "#2", 44 ], [ "#3", 66 ] ]

	? @@( MarquersSortedZZ() )
	#--> [ [ "#1", [ 12, 13 ] ], [ "#1", [ 26, 27 ] ], [ "#2", [ 44, 45 ] ], [ "#3", [ 66, 67 ] ] ]
}

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.66 second(s) in Ring 1.18
