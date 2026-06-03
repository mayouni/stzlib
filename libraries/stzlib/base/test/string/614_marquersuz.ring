# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #614.
#ERR Error (R3) : Calling Function without definition: marquersuz

load "../../stzBase.ring"

pr()

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? @@( MarquersUZ() ) # Or simply UniqueMarquersAndTheirPositions()
	#--> [ [ "#1", [ 12, 66 ] ], [ "#2", [ 26 ] ], [ "#3", [ 44 ] ] ]

	? @@( FindMarquer("#1") ) # Or ? OccurrencesOfMarquer("#1")
	#--> [ 12, 66]

	? @@( FindMarquer("#7") ) + NL
	#--> [ ]

	? MarquerByPosition(66)
	#--> #1

	? MarquerByPosition(44)
	#--> #3

	? MarquerByPositions([ 12, 66 ]) + NL
	#--> #1

	? MarquersByPositions([ 26, 44 ])
	#--> [ #2, #3 ]
}

pf()
# Executed in 0.10 second(s) in Ring 1.21
# Executed in 2.70 second(s) in Ring 1.18
