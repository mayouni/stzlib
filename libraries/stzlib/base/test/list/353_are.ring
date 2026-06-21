# Narrative
# --------
# Are() checks that EVERY item of a list satisfies a given predicate
# (or a whole set of predicates), returning a single TRUE/FALSE.
#
# A predicate is named with a category symbol like :Numbers, :Even,
# :Negative, :Positive, :Punctuation or :Chars. Passed a single symbol
# Are(:Numbers) it asks "are all items numbers?"; passed a list of
# symbols Are([ :Even, :Negative, :Numbers ]) it ANDs them together --
# every item must match every category. This turns a common all-of-a-kind
# guard into one readable expression instead of a hand-written loop.
#
# Extracted from stzlisttest.ring, block #353.

load "../../stzBase.ring"

pr()

? Q([ 1, 2, 3 ]).Are(:Numbers)
#--> TRUE

? Q([ -2, -4, -8 ]).Are([ :Even, :Negative, :Numbers ])
#--> TRUE

? Q([ 2, 4, 8 ]).Are([ :Even, :Numbers ])
#--> TRUE

? Q([ 2, 4, 8 ]).Are([ :Even, :Positive, :Numbers ])
#--> TRUE

? Q([ "(",";", ")" ]).Are([ :Punctuation, :Chars ])
#--> TRUE

pf()
# Executed in 0.28 second(s).
