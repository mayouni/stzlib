# Narrative
# --------
# Q(list).Are([...]) asserts that EVERY item in the list jointly
# satisfies a batch of conditions, returning a single boolean.
#
# The condition list is read conjunctively: [ :Lowercase, :Strings ]
# means \"all items are strings AND all are lowercase\". The first call
# confirms [ \"ring\", \"php\", \"python\" ] are all lowercase strings;
# the second confirms [ \"ABC\", \"DEF\", \"GHI\" ] are all uppercase
# strings. Both yield TRUE (printed as 1 by ?). This is the plural,
# whole-list counterpart to the singular IsA / EachItemIsA checks.
#
# Extracted from stzlisttest.ring, block #343.

load "../../stzBase.ring"

pr()

? Q([ "ring", "php", "python" ]).Are([ :Lowercase, :Strings ])
#--> TRUE

? Q([ "ABC", "DEF", "GHI" ]).Are([ :Uppercase, :Strings ])
#--> TRUE

pf()
# Executed in 0.11 second(s).
