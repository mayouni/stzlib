# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #662.

load "../../stzBase.ring"


o1 = new stzString("one;two;three;four;five")

? @@( o1.Splits(";") ) + NL
#--> [ "one", "two", "three", "four", "five" ]

? @@( o1.SplitsZ(";") ) + NL
#--> [ [ "one", 1 ], [ "two", 5 ], [ "three", 9 ], [ "four", 15 ], [ "five", 20 ] ]

? @@( o1.SplitsZZ(";") )
#--> [
#	[ "one", [ 1, 3 ] ], [ "two", [ 5, 7 ] ], [ "three", [ 9, 13 ] ],
#	[ "four", [ 15, 18 ] ], [ "five", [ 20, 23 ] ]
# ]

pf()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.20
