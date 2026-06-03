# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #466.

load "../../stzBase.ring"

pr()

StzListQ([ "a",[ [ [], "c", [ 1, [] ], 2 ] ],"b" ]) {

	Flatten()

	? @@( Content() )
	#--> [ "a", "c", 1, 2, "b" ]

	? NumberOfItems()
	#--> 5

	? ItemAtPosition(3)
	#--> 1

	? ItemAtPosition(5)
	#--> b
	
}

pf()
# Executed in 0.01 second(s).
