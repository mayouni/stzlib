# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #593.
#ERR Error (R14) : Calling Method without definition: deeplists

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", 1:3, NullObject(), "B", [ "C", 4:5, [ "V", 6:8, ["T", 9:12 ,"K"] ] ], "D" ])
? @@( o1.DeepLists() ) # Or ListsAtAnyLevel()
# DeepLists = EVERY list at any depth (depth-first pre-order), matching the
# ListsAtAnyLevel name. The container lists are included too, not only the
# innermost number-lists. (NullObject() is excluded -- objects aren't lists.)
# The old [[1,2,3],[4,5],[6,7,8],[9,10,11,12]] listed only the leaf number-lists.
#--> [ [ 1, 2, 3 ], [ "C", [ 4, 5 ], [ "V", [ 6, 7, 8 ], [ "T", [ 9, 10, 11, 12 ], "K" ] ] ], [ 4, 5 ], [ "V", [ 6, 7, 8 ], [ "T", [ 9, 10, 11, 12 ], "K" ] ], [ 6, 7, 8 ], [ "T", [ 9, 10, 11, 12 ], "K" ], [ 9, 10, 11, 12 ] ]

pf()
# Executed in 0.08 second(s).
