# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #547.

load "../../stzBase.ring"


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
