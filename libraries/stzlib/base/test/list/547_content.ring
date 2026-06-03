# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #547.
#ERR Error (R3) : Calling Function without definition: removewxt

load "../../stzBase.ring"

pr()

StzListQ([ 1, "a", "b", 2, 3, "c", 4, [ "..." ], "d" ]) {

	RemoveWXT('{
		isNumber(@item) or
		isString(@item)
	}')

	? @@(Content())
	#--> [ [ "..." ] ]
}

pf()
# Executed in 0.14 second(s).
