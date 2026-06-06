# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #288.

load "../../stzBase.ring"


o1 = new stzString("phpringringringpythonrubyruby")
#		       ↑   ↑   ↑  ↑
#                      4   8   12 15

? @@( o1.FindDupSecutiveSubString("ring") ) + NL
#--> [ 8, 12 ]

? @@( o1.FindDupSecutiveSubStringZZ("ring") ) + NL
#--> [ [ 8, 11 ], [ 12, 15 ] ]

? @@( o1.DupSecutiveSubStringZ("ring") ) + NL
#--> [ "ring", [ 8, 12 ] ]

? @@( o1.DupSecutiveSubStringZZ("ring") )
#--> [ "ring", [ [ 8, 11 ], [ 12, 15 ] ] ]

pf()
# Executed in 0.04 second(s).

#---------

pr()

o1 = new stzString("phpringringringpythonrubyruby")

? @@( o1.FindDupSecutiveSubStrings() ) + NL
#--> [ 9, 10, 26, 11, 8, 12 ]

? @@( o1.FindDupSecutiveSubStringsZZ() ) + NL
#--> [ [ 9, 12 ], [ 10, 13 ], [ 26, 29 ], [ 11, 14 ], [ 8, 11 ], [ 12, 15 ] ]

? @@( o1.DupSecutiveSubStrings() ) + NL
#--> [ "ingr", "ngri", "ruby", "grin", "ring" ]

? @@NL( o1.DupSecutiveSubStringsZ() ) + NL
#--> [
#	[ "ingr", [ 9 ] ],
#	[ "ngri", [ 10 ] ],
#	[ "ruby", [ 26 ] ],
#	[ "grin", [ 11 ] ],
#	[ "ring", [ 8, 12 ] ]
# ]

? @@NL( o1.DupSecutiveSubStringsZZ() )
#--> [
#	[ "ingr", [ [ 9, 12 ] ] ],
#	[ "ngri", [ [ 10, 13 ] ] ],
#	[ "ruby", [ [ 26, 29 ] ] ],
#	[ "grin", [ [ 11, 14 ] ] ],
#	[ "ring", [ [ 8, 11 ], [ 12, 15 ] ] ]
# ]

o1.RemoveDupSecutiveSubStrings()
? o1.Content()

pf()
# Executed in 0.17 second(s).
