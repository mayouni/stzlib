# Narrative
# --------
# Counting list items whose value falls inside a numeric range, with the
# exclusive-vs-inclusive bounds distinction.
#
# NumberOfItemsWF walks the list and counts items for which the anonymous
# function returns TRUE. Here each item x is wrapped with Q(x) and tested.
# IsBetween(1, 4) uses EXCLUSIVE bounds: on [ -1, 2, 3, 4 ] only 2 and 3
# qualify, so the count is 2. IsBetweenIB(1, 4) uses INCLUSIVE bounds (the
# "IB" suffix = Including Bounds), so 2, 3 and 4 all qualify, giving 3. The
# pair shows how Softanza exposes both range semantics through a single
# naming convention.
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
