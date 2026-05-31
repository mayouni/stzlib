# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #441.

load "../../../stzBase.ring"


StzListQ([ -1 , 2, 3, 4 ]) {

	? NumberOfItemsWXT("Q(@item).IsBetween(1, 4)")
	#--> 2

	? NumberOfItemsWXT("Q(@item).IsBetweenIB(1, 4)")
	#--> 3
}

pf()
# Executed in 0.12 second(s) in Ring 1.21
