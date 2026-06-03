# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #626.

load "../../stzBase.ring"

pr()

o1 = new stzString("My name is #2, may age is #1, and my job is #3.")
? @@( o1.MarquersSortedInDescendingZZ() )
#--> [ [ "#3", [ 12, 14 ] ], [ "#2", [ 27, 29 ] ], [ "#1", [ 45, 47 ] ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.27 second(s) in Ring 1.18
# Executed in 0.41 second(s) in Ring 1.17
