# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #340.
#ERR Error (R14) : Calling Method without definition: findanyboundedbyzz

load "../../stzBase.ring"

pr()

o1 = new stzString("aa***aa**aa***")

? @@( o1.FindAnyBoundedBy([ "aa", "aa" ]) )
#--> [ 3, 8 ]

? @@( o1.FindAnyBoundedByZZ([ "aa", "aa" ]) )
#--> [ [ 3, 5 ], [ 8, 9 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.17
