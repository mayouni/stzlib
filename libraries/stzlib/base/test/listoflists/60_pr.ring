# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #60.

load "../../stzBase.ring"


o1 = new stzListOfLists([ 1:3, 4:7, 8:10 ])

//? @@( o1.MergeQ().Content() )
#--> Error: Can't merge the list of lists! Instead
# you can return a merged copy of it using Merged()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10, [ "A", 0:1, "B" ] ])
? @@( o1.Merged() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, "A", [ 0, 1 ], "B" ]

//? @@( o1.FlattenQ().Content() )
#--> Error: Can't flatten the list of lists! Instead
# you can return a flattened copy of it using Merged()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10, [ "A", 0:1, "B" ] ])
? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, "A", 0, 1, "B" ]

pf()
# Executed in 0.06 second(s)
