# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #139.

load "../../stzBase.ring"

pr()

# DupOrigins = DuplicatesOrigins

o1 = new stzList([ "A", "B", "B", "B", "b", "C", "B", "C", "C", "c", "A" ])
? o1.FindDupSecutiveItems()
#--> [ 3, 4, 9 ]

? @@( o1.DupSecutiveItemsZ() )
#--> [ [ "B", [ 3, 4 ] ], [ "C", [ 9 ] ] ]

? @@( o1.FindThisDupSecutiveItem("B") )
#--> [ 3, 4 ]

? @@( o1.FindThisDupSecutiveItemCS("B", :CS = FALSE) )
#--> [ 3, 4, 5 ]

? @@( o1.DupSecutiveItemCSZ("B", FALSE) )
#--> [ "B", [ 3, 4, 5 ] ]

o1.RemoveDupSecutiveItemCS("B", FALSE)
? @@( o1.Content() )
#--> [ "A", "B", "C", "B", "C", "C", "c", "A" ]

pf()
# Executed in 0.01 second(s).
