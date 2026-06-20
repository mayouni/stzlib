# Narrative
# --------
# NListified(n): reshape a flat list so EVERY item becomes a sublist of
# exactly n slots.
#
# Each item is padded out (or, if it is already a longer sublist,
# trimmed) to length n. A scalar becomes itself plus padding; a 2-item
# sublist like [ "a", "b" ] grows to fill n; the range 1:5 (expanded to
# [1,2,3,4,5]) is clipped to its first n. The padding filler is the
# empty string "". This is the building block behind rectangular /
# tabular views of a ragged list.
#
# Extracted from stzlisttest.ring, block #109.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 1:5, "hi!", StzNullObjectQ(), [ "a", "b" ] ])

? @@( o1.NListified(3) )
#--> [ [ 1, "", "" ], [ 1, 2, 3 ], [ "hi!", "", "" ], [ @nullobject, "", "" ], [ "a", "b", "" ] ]
#
# NOTE: the historical recorded output used NULL fillers and @noname for
# the null object. The authoritative NListify pads with the empty string
# "" and StzNullObjectQ() now renders as @nullobject -- output corrected
# to the real run.

pf()
# Executed in almost 0 second(s)
