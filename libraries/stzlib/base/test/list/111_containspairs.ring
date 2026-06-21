# Narrative
# --------
# Detecting and harvesting the two-element sublists ("pairs") inside a stzList.
#
# A "pair" here is any item that is itself a list of exactly two elements,
# such as [ "a", "b" ]. The family answers a graded set of questions about
# them: ContainsPairs() asks merely whether any exist (TRUE here); FindPairs()
# returns the 1-based positions of every pair (3, 5, 6); Pairs() returns the
# pair values in order, duplicates included; PairsU() returns the unique pairs;
# PairsZ() zips each unique pair to the list of positions where it occurs; and
# Pairified() returns the whole list normalized so every non-pair scalar is
# widened into a [value, NULL] pair, giving a uniform list-of-pairs shape.
#
# Extracted from stzlisttest.ring, block #111.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, [ "a", "b" ], 4, [ "c", "d"], [ "a", "b" ] ])
? o1.ContainsPairs()
#--> TRUE

? @@( o1.FindPairs() )
#--> [ 3, 5, 6 ]

? @@( o1.Pairs() )
#--> [ [ "a", "b" ], [ "c", "d" ], [ "a", "b" ] ]

? @@( o1.PairsU() )
#--> [ [ "a", "b" ], [ "c", "d" ] ]

? @@( o1.PairsZ() ) + NL
#--> [
#	[ [ "a", "b" ], [ 3, 6 ] ],
#	[ [ "c", "d" ], [ 5 ] ]
# ]

? @@( o1.Pairified() )
#--> [
#	[ 1, NULL ], [ 2, NULL ], [ "a", "b" ],
#	[ 4, NULL ], [ "c", "d" ], [ "a", "b" ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
