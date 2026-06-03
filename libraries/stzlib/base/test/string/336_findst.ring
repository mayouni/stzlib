# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #336.
#ERR Error (R14) : Calling Method without definition: findst

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? @@( o1.FindST( "♥♥♥", :StartingAt = 6 ) )
#--> [8, 13 ]

? @@( o1.FindSTZ( "♥♥♥", :StartingAt = 6 ) )
#--> [ 8, 13 ]

? @@( o1.FindSTZZ( "♥♥♥", :StartingAt = 6 ) )
#--> [ 8, 10], [13, 15] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.17
