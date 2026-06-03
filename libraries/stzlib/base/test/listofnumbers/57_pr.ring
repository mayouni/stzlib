# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #57.

load "../../stzBase.ring"


StzListOfNumbersQ([ 1, 2, 3 ]) {

	? @@( Content() )
	#--> [ 1, 2, 3 ]
 
	AddToEach(3)
	? @@( Content() )
	#--> [ 4, 5, 6 ]

	MultiplyEachBy(3)
	? @@( Content() )
	#--> [ 12, 15, 18 ]

	DivideEachBy(3)
	? @@( Content() )
	#--> [ 4, 5, 6 ]
}

pf()
# Executed in 0.04 second(s)
