# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #426.

load "../../stzBase.ring"


o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])

o1.SplitWXT('@CurrentItem = "*"')

? @@( o1.Content() )
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

pf()
# Executed in 0.09 second(s) in Ring 1.21
