# Narrative
# --------
# #perf
#
# Extracted from stzStringTest.ring, block #608.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"


pr()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? @@( Marquers() ) + NL
	#--> [ "#1", "#2", "#3", "#1" ]

	? @@( MarquersPositions() ) + NL # or FindMarquers()
	#--> [ 12, 26, 44, 66 ]

	? @@( MarquersZ() ) + NL # Or MarquersAndPositions()
	#--> [ [ "#1", 12 ], [ "#2", 26 ], [ "#3", 44 ], [ "#1", 66 ] ]

	? @@( MarquersAndSections() ) + NL # Or MarquersAndSections()
	#--> [ [ "#1", [ 12, 13 ] ], [ "#2", [ 26, 27 ] ], [ "#3", [ 44, 45 ] ], [ "#1", [ 66, 67 ] ] ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 2.49 second(s) in Ring 1.19
