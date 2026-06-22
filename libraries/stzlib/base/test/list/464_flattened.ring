# Narrative
# --------
# Flattened() collapses an arbitrarily nested list into a single
# flat list, in depth-first reading order.
#
# Given [ "a", [ "b", [ "c", "d" ], "e" ], "f" ], the method walks
# every level of nesting and pulls each leaf out in the order it
# appears, yielding [ "a", "b", "c", "d", "e", "f" ]. This is the
# Softanza idiom for normalizing tree-shaped list literals into a
# linear sequence without writing a manual recursion. @@() renders
# the result in readable bracketed form.
#
# Extracted from stzlisttest.ring, block #464.

load "../../stzBase.ring"

pr()

? @@( StzListQ([ "a", [ "b", [ "c",  "d" ], "e" ], "f" ]).Flattened() )
#--> [ "a","b","c","d","e","f" ]

pf()
# Executed in almost 0 second(s).
