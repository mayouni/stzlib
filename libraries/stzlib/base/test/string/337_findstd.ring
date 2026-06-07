# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #337.

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindSTD( "♥♥♥", :StartingAt = 6, :Backward )
#--> [8, 13 ]

? o1.FindSTDZ( "♥♥♥", :StartingAt = 6, :Backward )
#--> [ "♥♥♥", [13, 8] ]

? @@( o1.FindAsSectionsSTD("♥♥♥", :StartingAt = 12, :Backward) )
#--> [ [ 8, 10 ], [ 3, 5 ] ]

? @@( o1.FindSTDZZ( "♥♥♥", :StartingAt = 12, :Backward ) )
#--> [ [ 8, 10 ], [ 3, 5 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
