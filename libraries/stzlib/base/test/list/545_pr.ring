# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #545.

load "../../stzBase.ring"


StzListQ([ "a", "b", [], "c", [] ]) {
	? OnlyWhereXT('{ isString(@item) }')
	#--> [ "a", "b", "c" ]
}

pf()
# Executed in 0.12 second(s).
