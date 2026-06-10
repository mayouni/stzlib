# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #598.

load "../../stzBase.ring"

pr()

StzStringQ("ring is not the ring you ware but the ring you program with") {
	? @@( FindAllOccurrencesCS(:Of = "ring", :CS = FALSE) )
	#--> [ 1, 17, 39 ]

	? @@( FindAsSectionsCS(:Of = "ring", :CS = FALSE) )
	#--> [ [ 1, 4 ], [ 17, 20 ], [ 39, 42 ] ]

	? @@( FindOccurrences([1, 3], :Of = "ring") )
	#--> [1, 39]

	? @@( FindOccurrences([1, 3], :Of = "foo") )
	#--> [ ]
}

pf()
# Executed in 0.06 second(s) in Ring 1.22
