# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #571.
#ERR Error (R14) : Calling Method without definition: findtheseboundszz

load "../../stzBase.ring"

pr()

#                       5     11             26        36    42     50
#                       v     v              v         v     v      v
o1 = new stzString("The <<Ring>> programming <<language>> is <<Waooo!>>")

? @@( o1.FindTheseBounds("<<", ">>") ) + NL
#--> [ 5, 11, 26, 36, 42, 50 ]

? @@( o1.FindTheseBoundsZZ("<<", ">>") ) + NL
#--> [ [ 5, 6 ], [ 11, 12 ], [ 26, 27 ], [ 36, 37 ], [ 42, 43 ], [ 50, 51 ] ]

o1.RemoveTheseBounds("<<", ">>")
? o1.Content()
#--> The Ring programming language is Waooo!

pf()
# Executed in 0.06 second(s) in Ring 1.22
