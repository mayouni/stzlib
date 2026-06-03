# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #334.

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? @@( o1.Find( "♥♥♥" ) ) # or FindOccurrences( :Of = "♥♥♥" )
#--> [3, 8, 13 ]

? @@( o1.FindZ( :Of = "♥♥♥") )
#--> [ 3, 8, 13 ]

? @@( o1.FindZZ( :Of = "♥♥♥") )
#--> [ [3, 5], [8, 10], [13, 15] ]

pf()
# Executed in 0.06 second(s) in Ring 1.21
