# Narrative
# --------
# Reversing the order of a list's items with Reversed().
#
# StzListQ("A":"E") builds the list [ "A", "B", "C", "D", "E" ]
# from the range, and Reversed() returns a new list with the items
# in the opposite order. ItemsReversed() is an explicit alias that
# reads more naturally when the intent is to reverse the items
# themselves; both produce the same result. The operation is
# non-destructive, returning a fresh list rather than mutating the
# receiver.
#
# Extracted from stzlisttest.ring, block #523.

load "../../stzBase.ring"

pr()

? @@( StzListQ("A":"E").Reversed() )
#--> [ "E", "D", "C", "B", "A" ]

? @@( StzListQ("A":"E").ItemsReversed() )
#--> [ "E", "D", "C", "B", "A" ]

pf()
# Executed in almost 0 second(s).
