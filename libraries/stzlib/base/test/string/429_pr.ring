# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #429.

load "../../stzBase.ring"


o1 = new stzString("book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12")

? @@( o1.Numbers() ) + NL
#--> [ "12.34", "-56.30", "12.34", "77.12" ]

? @@( o1.UniqueNumbers() ) + NL
#--> [ "12.34", "-56.30", "77.12" ]

#--

? @@( o1.FindNumbers()) + NL
#--> [ 7, 21, 39, 55 ]

? @@( o1.FindNumbersZZ() ) + NL # FindNumbersAsSections
#--> [ [ 7, 11 ], [ 21, 26 ], [ 39, 43 ], [ 55, 59 ] ]

? @@NL( o1.NumbersZ() ) + NL # Same as NumbersAndTheirPositions()
#--> [
#	[ "12.34", [ 7, 39 ] ],
#	[ "-56.30", [ 21 ] ],
#	[ "77.12", [ 55 ] ]
# ]

? @@NL( o1.NumbersZZ() ) # Same as NumbersAndTheirSections()
#-->
# [
# 	[ "12.34", 	[ [ 7, 11 ], [ 39, 43 ]	] ],
#	[ "-56.30",	[ [ 21, 26 ] ] ],
#	[ "77.12", 	[ [ 55, 59 ] ] ]
# ]

pf()
# Executed in 0.06 second(s) in Ring 1.21
