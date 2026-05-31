# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #316.

load "../../../stzBase.ring"


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
# Executed in 0.08 second(s) in Ring 1.22
