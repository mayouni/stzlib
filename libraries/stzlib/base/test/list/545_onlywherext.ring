# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #545.
#ERR Error (R3) : Calling Function without definition: onlywherext

load "../../stzBase.ring"

pr()

StzListQ([ "a", "b", [], "c", [] ]) {
	? OnlyWhereXT('{ isString(@item) }')
	#--> [ "a", "b", "c" ]
}

pf()
# Executed in 0.12 second(s).
