# Narrative
# --------
# Subtracting a These() value-set from a stzList to drop matching items.
#
# These([...]) wraps a plain list so that the minus operator on a
# stzList reads it as a set of values to remove. o1 - These(list)
# returns every element of o1 that is NOT present in that value-set.
# Here ["a","b","c"] minus ["b","a","c","q"] removes a, b and c
# (the extra "q" simply has nothing to match), leaving the empty
# list. @@() renders that empty result as [ ].
#
# Extracted from stzlisttest.ring, block #459.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c" ])
? @@( o1 - These([ "b", "a", "c" , "q" ]) )
#--> []

pf()
# Executed in almost 0 second(s).
