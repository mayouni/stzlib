# Narrative
# --------
# Searching a list for several values at once, two complementary ways.
#
# FindMany() takes a set of target values and returns a single flat,
# sorted list of every position where any of them occurs -- here
# :one, :two and :four land at positions 1, 2, 3, 5, 6. TheseItemsZ()
# answers the grouped question instead: it returns a hashlist keyed by
# each searched value mapped to the list of its positions
# (:one = [ 1, 3, 5 ], :two = [ 2 ], :four = [ 6 ]). The Z-suffixed
# name signals the structured (per-key) form, versus the flattened
# index list from FindMany().
#
# Extracted from stzlisttest.ring, block #468.

load "../../stzBase.ring"

pr()

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])
? o1.FindMany([ :one, :two, :four ])
#--> [ 1, 2, 3, 5, 6 ]

? o1.TheseItemsZ([ :one, :two, :four ])
#--> [ :one = [ 1, 3, 5 ], :two = [ 2 ], :four = [ 6 ] ]

pf()
# Executed in almost 0 second(s).
