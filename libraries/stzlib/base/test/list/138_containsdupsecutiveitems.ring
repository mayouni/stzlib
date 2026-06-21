# Narrative
# --------
# Detecting and removing "DupSecutive" items -- duplicate values that sit
# in consecutive (adjacent) positions inside a list.
#
# Softanza coins DupSecutive = Duplicate + Consecutive: a run of two or more
# identical items standing next to each other. ContainsDupSecutiveItems()
# answers yes/no; FindDupSecutiveItems() returns the positions of the
# trailing members of each run (3,4,9 for the B,B,B and C,C runs), while the
# *CS(FALSE) form folds case so the lowercase b and c join their runs
# (3,4,5,9,10). The Z-suffixed variants pair each value with its run
# positions, and RemoveDupSecutiveItemsCS collapses each adjacent run down
# to a single item -- distinct from RemoveDuplicates(), which globally keeps
# only first occurrences. Note Duplicates() reports all repeated values
# anywhere (A,B,C), not just the consecutive ones.
#
# Extracted from stzlisttest.ring, block #138.

load "../../stzBase.ring"

pr()

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
