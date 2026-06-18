# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #441.

load "../../stzBase.ring"

pr()

StzListQ([ -1 , 2, 3, 4 ]) {

	? NumberOfItemsWF( func x { return Q(x).IsBetween(1, 4) } )
	#--> 2

	? NumberOfItemsWF( func x { return Q(x).IsBetweenIB(1, 4) } )
	#--> 3
}

pf()
# Executed in 0.12 second(s) in Ring 1.21
