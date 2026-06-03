# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #546.
#ERR Error (R3) : Calling Function without definition: removewxt

load "../../stzBase.ring"

pr()

StzListQ([ "a", "b", [], "c", [] ]) {
	RemoveWXT('{
		isList(@item) and Q(@item).IsEmpty()
	}')

	? Content()
	#--> [ "a", "b", "c" ]
}

pf()
# Executed in 0.13 second(s).
