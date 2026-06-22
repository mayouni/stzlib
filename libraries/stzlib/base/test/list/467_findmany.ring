# Narrative
# --------
# Searching a list for several target values at once: FindMany and TheseItemsZ.
#
# FindMany([ :one, :five ]) scans the host list and returns the flat, ordered
# list of every position where any requested item occurs -- :one sits at 1, 3, 5
# and :five is absent, so the result is [ 1, 3, 5 ] (note :two at position 2 is
# NOT in the search set, so it is not reported). TheseItemsZ returns the
# structured Z-form: a pair-list mapping each requested item to its own position
# list, keeping per-item hits and misses (the empty list for the absent :five).
# Rendered with @@() the pairs read [ [ "one", [ 1, 3, 5 ] ], [ "five", [ ] ] ].
#
# Extracted from stzlisttest.ring, block #467.

load "../../stzBase.ring"

pr()

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])

? o1.FindMany([ :one, :five ])
#--> [ 1, 3, 5 ]

? @@(o1.TheseItemsZ([ :one, :five ]))
#--> [ [ "one", [ 1, 3, 5 ] ], [ "five", [ ] ] ]

pf()
# Executed in almost 0 second(s).
