# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #59.

load "../../../stzBase.ring"


StzListOfNumbersQ([ 2, 4, 8 , 10 , 12 ]) {

	AddManyOneByOne([ 8, 6, 2, 0, -2 ])
	? @@( Content() )
	#--> [ 10, 10, 10 , 10 , 10 ]

	SubStructManyOneByOne([ 5, 5, 5, 5, 5 ])
	? @@( Content() )
	#--> [ 5, 5, 5, 5, 5 ]

	MultiplyByManyOneByOne([ 1, 2, 3, 4, 5 ])
	? @@( Content() )
	#--> [ 5, 10, 15, 20, 25 ]

	DivideByManyOneByOne([ 5, 5, 5, 5, 5 ])
	? @@( Content() )
	#--> [ 1, 2, 3, 4, 5 ])

}

pf()
# Executed in 0.05 second(s)
