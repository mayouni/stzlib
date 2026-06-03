# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #335.
#ERR Error (R14) : Calling Method without definition: findd

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? @@( o1.FindD( "♥♥♥", :Backward ) )
#--> [ 13, 8, 3 ]

? @@( o1.FindAsSectionsD( "♥♥♥", :Backward ) )
#--> [ [13, 5], [8, 10], [3, 5] ]

? @@( o1.FindDZ( "♥♥♥", :Backward) )
#--> [ 13, 8, 3 ]

? @@( o1.FindDZZ( "♥♥♥", :Backward) )
#--> [ [ 13, 15 ], [ 8, 10 ], [ 3, 5 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
