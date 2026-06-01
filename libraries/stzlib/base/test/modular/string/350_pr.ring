# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #350.

load "../../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindD( :Of = "♥♥♥", :Backward ) ) 
#--> [ 13, 8, 3 ]

? @@( o1.FindTheseOccurrencesD([ 1, 2], :Of = "♥♥♥", :Backward) )
#--> [ 13, 8 ]

? @@( o1.FindTheseOccurrencesAsSectionsD([ 1, 2], :Of = "♥♥♥", :Backward) )
#--> [ [ 13, 15 ], [ 8, 10 ] ]

? @@( o1.FindTheseOccurrencesSD([ 1, 2], :Of = "♥♥♥", :StartingAt = 12, :Bakcward) )
#--> [ 8, 3 ]

? @@( o1.FindTheseOccurrencesAsSectionsSTD([ 1, 2], :Of = "♥♥♥", :StartingAt = 12, :Backward) )
#--> [ [ 8, 10 ], [ 3, 5 ] ]

pf()
# Executed in 0.10 second(s)
