# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #348.

load "../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindD("♥♥♥", :Forward) )
#--> [ 3, 8, 13 ]

? @@( o1.FindAsSectionsD("♥♥♥", :Forward) )
#--> [ [ 3, 5 ], [ 8, 10 ], [ 13, 15 ] ]

#--

? @@( o1.FindD("♥♥♥", :Backward) )
#--> [ 13, 8, 3 ]

? @@( o1.FindAsSectionsD("♥♥♥", :Backward) )
#--> [ [ 13, 15 ], [ 8, 10 ], [ 3, 5 ] ]

#--

? @@( o1.FindSTD("♥♥♥", :StartingAt = 6, :Forward) )
#--> [ 8, 13 ]

? @@( o1.FindAsSectionsSTD("♥♥♥", :StartingAt = 6, :Forward) )
#--> [ [ 8, 10 ], [ 13, 15 ] ]

#--

? @@( o1.FindSTD("♥♥♥", :StartingAt = 14, :Backward) )
#--> [8, 3]

? @@( o1.FindAsSectionsSTD("♥♥♥", :StartingAt = 14, :Backward) )
#--> [ [ 8, 10 ], [ 3, 5 ] ]

pf()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.18 second(s) in Ring 1.18
