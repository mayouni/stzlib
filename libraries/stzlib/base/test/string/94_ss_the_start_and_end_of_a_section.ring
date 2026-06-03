# Narrative
# --------
# SS ~> The start and end of a section
#
# Extracted from stzStringTest.ring, block #94.

load "../../stzBase.ring"


pr()

o1 = new stzString("123♥♥678♥♥123♥♥678")
? @@( o1.FindSSZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindInSectionZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindBetweenZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

pf()
# Executed in 0.08 second(s) in Ring 20
# Executed in 0.01 second(s) in Ring 1.22
