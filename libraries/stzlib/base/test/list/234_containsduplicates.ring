# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #234.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "_", "ONE", "_", "_", "TWO", "_", "THREE", "*", "*" ])

? o1.ContainsDuplicates()
#--> TRUE

? @@( o1.FindDuplicates() )
#--> [ 3, 4, 6, 9 ]

? @@( o1.Duplicates() )
#--> [ "_", "*" ]

? @@( o1.DuplicatesZ() ) # Or DuplicatesAndTheirPositions()
#--> [ [ "_", [ 3, 4, 6 ] ], [ "*", [ 9 ] ] ]

o1.RemoveDuplicates()
? @@( o1.Content() )
#--> [ "_", "ONE", "TWO", "THREE", "*" ]

pf()
# Executed in 0.01 second(s) in ring 1.21
# Executed in 0.55 second(s) in Ring 1.17
