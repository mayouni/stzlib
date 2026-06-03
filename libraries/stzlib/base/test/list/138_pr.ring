# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #138.

load "../../stzBase.ring"


# DupSecutive = Duplicate + Consecutive

o1 = new stzList([ "A", "B", "B", "B", "b", "C", "B", "C", "C", "c", "A" ])
#                             ^    ^    ^                   ^    ^
? o1.ContainsDupSecutiveItems()
#--> TRUE

? o1.FindDupSecutiveItems()
#--> [ 3, 4, 9 ]

? o1.FindDupSecutiveItemsCS(FALSE)
#--> [ 3, 4, 5, 9, 10 ]

? o1.Duplicates()
#--> [ "A", "B", "C" ]

? o1.DupSecutiveItems()
#--> [ "B", "C" ]

? @@( o1.DupSecutiveItemsZ() ) + NL
#--> [ [ "B", [ 3, 4 ] ], [ "C", [ 9 ] ] ]

? @@( o1.DupSecutiveItemsCSZ(FALSE) ) + NL
#--> [ [ "B", [ 3, 4, 5 ] ], [ "C", [ 9, 10 ] ] ]

o1.RemoveDupSecutiveItemsCS(FALSE)
? @@( o1.Content() ) + nl
#--> [ "A", "B", "C", "B", "C", "A" ]

o1.RemoveDuplicates()
? @@( o1.Content() )
# [ "A", "B", "C" ]

pf()
# Executed in 0.02 second(s).
