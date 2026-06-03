# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #424.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])

o1.SplitW('This[@i] = "*"')

? @@( o1.Content() )
# [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

pf()
# Executed in 0.07 second(s) in Ring 1.21
