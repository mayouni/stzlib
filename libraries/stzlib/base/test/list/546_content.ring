# Narrative
# --------
# RemoveW with a Q(...) predicate inside the condition.
#
# The block '{ isList(@item) and Q(@item).IsEmpty() }' selects every item
# that is an empty list; RemoveW deletes them, so [ "a", "b", [], "c", [] ]
# collapses to [ "a", "b", "c" ]. Wrapping @item in Q(...) exposes the full
# stzList query surface (here IsEmpty) inside the engine-evaluated condition.
# W is the single performant + expressive conditional form.
#
# Extracted from stzlisttest.ring, block #546.

load "../../stzBase.ring"

pr()

StzListQ([ "a", "b", [], "c", [] ]) {
	RemoveW('{
		isList(@item) and Q(@item).IsEmpty()
	}')

	? Content()
	#--> [ "a", "b", "c" ]
}

pf()
# Executed in 0.13 second(s).
