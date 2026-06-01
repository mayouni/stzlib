# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #591.

load "../../../stzBase.ring"


o1 = new stzString("Hello <<<Ring>>, the nice __Ring__ and beautiful ((Ring))!")

? @@( o1.BoundsOf("Ring") )
#--> [ "<<<", ">>", "__", "__", "((", "))" ]

? @@( o1.FirstBoundsOf("Ring") )
#--> [ "<<<", "__", "((" ]

? @@( o1.LastBoundsOf("Ring") )
#--> [ ">>", "__", "))" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.20
