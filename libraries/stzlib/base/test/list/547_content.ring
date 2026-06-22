# Narrative
# --------
# RemoveW with a compound (OR) condition.
#
# The block '{ isNumber(@item) or isString(@item) }' selects every scalar
# (numbers and strings) and RemoveW deletes them, leaving only the nested
# list: [ 1, "a", "b", 2, 3, "c", 4, [ "..." ], "d" ] -> [ [ "..." ] ].
# W is the single performant + expressive conditional form -- the predicate
# can be any engine-evaluable boolean expression over @item.
#
# Extracted from stzlisttest.ring, block #547.

load "../../stzBase.ring"

pr()

StzListQ([ 1, "a", "b", 2, 3, "c", 4, [ "..." ], "d" ]) {

	RemoveW('{
		isNumber(@item) or
		isString(@item)
	}')

	? @@(Content())
	#--> [ [ "..." ] ]
}

pf()
# Executed in 0.14 second(s).
