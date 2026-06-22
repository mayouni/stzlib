# Narrative
# --------
# OnlyWhere(condition): keep only the items matching a W condition.
#
# OnlyWhere is the readable, intent-revealing alias of ItemsW: it returns the
# items for which the condition is true. '{ isString(@item) }' keeps the
# strings out of [ "a", "b", [], "c", [] ], dropping the empty lists, so the
# result is [ "a", "b", "c" ]. W is the single performant + expressive
# conditional form (the old WhereXT/WXT extended forms are retired).
#
# Extracted from stzlisttest.ring, block #545.

load "../../stzBase.ring"

pr()

StzListQ([ "a", "b", [], "c", [] ]) {
	? OnlyWhere('{ isString(@item) }')
	#--> [ "a", "b", "c" ]
}

pf()
# Executed in 0.12 second(s).
