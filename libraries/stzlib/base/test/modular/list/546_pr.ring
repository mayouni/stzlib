# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #546.

load "../../../stzBase.ring"


StzListQ([ "a", "b", [], "c", [] ]) {
	RemoveWXT('{
		isList(@item) and Q(@item).IsEmpty()
	}')

	? Content()
	#--> [ "a", "b", "c" ]
}

pf()
# Executed in 0.13 second(s).
