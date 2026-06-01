# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #423.

load "../../../stzBase.ring"


o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])
? o1.FindW('This[@i] = "*"')
#--> [4, 7]
# Executed in 0.05 second(s)

o1.SplitAtPositions([ 4, 7])
? @@( o1.Content() )
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

pf()
# Executed in 0.08 second(s) in Ring 1.21
