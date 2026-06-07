# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #421.

load "../../stzBase.ring"

pr()

#                      4   8 01  4 6 89  23
o1 = new stzString("...12..1212..121212..12.")

? @@( o1.FindMadeOf("12") ) + NL
#--> [ 4, 8, 14, 22 ]

? @@( o1.FindMadeOfZZ("12") ) + NL # Or FindMadeOfAsSections
#--> [ [ 4, 5 ], [ 8, 11 ], [ 14, 19 ], [ 22, 23 ] ]

? @@( o1.SubStringsMadeOf("12") ) + NL
#--> [ "12", "1212", "121212", "12" ]

? @@NL( o1.SubStringsMadeOfZZ("12") )
#--> [
#	[ "12", [ 4, 5 ] ],
#	[ "1212", [ 8, 11 ] ],
#	[ "121212", [ 14, 19 ] ],
#	[ "12", [ 22, 23 ] ]
# ]

StopProfiler()

pf()
# Executed in 0.06 second(s) in Ring 1.22
