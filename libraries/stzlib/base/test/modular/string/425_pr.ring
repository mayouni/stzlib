# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #425.

load "../../../stzBase.ring"


o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])

? o1.FindWXT('@CurrentItem = "*"')

o1.SplitAtPositions([ 4, 7 ])
? @@( o1.Content() )
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

pf()
# Executed in 0.10 second(s) in Ring 1.21
# Executed in 0.44 second(s) in Ring 1.17
