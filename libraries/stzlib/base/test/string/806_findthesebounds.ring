# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #806.
#ERR Error (R14) : Calling Method without definition: findboundedby

load "../../stzBase.ring"

pr()

o1 = new stzString("بسم الله الرّحمن الرّحيم")

? @@( o1.FindTheseBounds("بسم", "الرّحيم") )
#--> [ 1, 18 ]

? @@( o1.FindBoundedBy([ "بسم", "الرّحيم" ]) ) + NL
#--> [ 4 ]

#--

? @@( o1.FindTheseBoundsZZ("بسم", "الرّحيم") )
#--> [ [ 1, 3 ], [ 18, 24 ] ]

? @@( o1.FindBoundedByZZ([ "بسم", "الرّحيم" ]) )
#--> [ [ 4, 17 ] ]

pf()
# Executed in 0.01 second(s).
