# Narrative
# --------
# DEEP nested-bracket extraction, with and without the bounds. The ZZ form gives
# the content span [open+1 .. close-1]; the IBZZ form keeps the bounds [open ..
# close]. Regions are ordered leaves first, then their parents (close order).
# Codepoint-correct (the bullets are multibyte).
#
# Extracted from stzlisttest.ring, block #316.

load "../../stzBase.ring"

pr()

#                   1..4.6..v.1..vv..8..vv
o1 = new stzString("[••[•[••]•[••]]••[••]]")
#                   ^..^.^..9.^..45..^..21

? @@( o1.DeepFindSubStringsBoundedByZZ([ "[", "]" ]) ) + NL
#--> [ [ 7, 8 ], [ 12, 13 ], [ 19, 20 ], [ 5, 14 ], [ 2, 21 ] ]

? @@NL( o1.DeepSubStringsBoundedByZZ([ "[", "]" ]) ) + NL
#--> [
#	[ "••", [ 7, 8 ] ],
#	[ "••", [ 12, 13 ] ],
#	[ "••", [ 19, 20 ] ],
#	[ "•[••]•[••]", [ 5, 14 ] ],
#	[ "••[•[••]•[••]]••[••]", [ 2, 21 ] ]
# ]

#--

? @@( o1.DeepFindSubStringsBoundedByIBZZ([ "[", "]" ]) ) + NL
#--> [ [ 6, 9 ], [ 11, 14 ], [ 18, 21 ], [ 4, 15 ], [ 1, 22 ] ]

? @@NL( o1.DeepSubStringsBoundedByIBZZ([ "[", "]" ]) ) + NL
#--> [
#	[ "[••]", [ 6, 9 ] ],
#	[ "[••]", [ 11, 14 ] ],
#	[ "[••]", [ 18, 21 ] ],
#	[ "[•[••]•[••]]", [ 4, 15 ] ],
#	[ "[••[•[••]•[••]]••[••]]", [ 1, 22 ] ]
# ]

StopProfiler()

pf()
# Executed in 0.08 second(s) in Ring 1.22
