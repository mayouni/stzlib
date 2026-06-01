# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #407.

load "../../../stzBase.ring"


o1 = new stzString("book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12")

? @@( o1.Find("12.34") ) + NL
#--> [ 7, 39 ]

? @@( o1.FindAsSections("12.34") ) + NL
#--> [ [ 7, 11 ], [ 39, 43 ] ]

? @@( o1.FindManyAsSections([ "12.34", "-56.30", "77.12" ]) )
#--> [ [ 7, 11 ], [ 21, 26 ], [ 39, 43 ], [ 55, 59 ] ]

pf()
# Executed in 0.05 second(s) in Ring 1.21
