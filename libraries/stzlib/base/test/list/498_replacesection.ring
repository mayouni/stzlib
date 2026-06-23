# Narrative
# --------
# Replaces a contiguous range of list items with a single replacement value.
#
# ReplaceSection(n1, n2, val) removes the slice spanning positions n1..n2
# and drops the replacement value in its place as ONE element. Here items
# 4..6 ("1","2","3") are swapped out for the sublist [ "*", "*", "*", "*" ],
# which lands as a single nested list rather than being spliced in flat.
# This is the deliberate Softanza idiom: the section becomes whatever you
# hand it, preserving the value's own structure (use a splicing variant if
# you want the replacement flattened into the host list).
#
# Extracted from stzlisttest.ring, block #498.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C", "1", "2", "3", "D", "E" ])
o1.ReplaceSection(4, 6, [ "*", "*", "*", "*" ])
? @@( o1.Content() )
#--> [ "A", "B", "C", [ "*", "*", "*", "*" ], "D", "E" ]

pf()
# Executed in almost 0 second(s).
