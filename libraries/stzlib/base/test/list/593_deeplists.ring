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
#--> [ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ], [ 9, 10, 11, 12 ] ]

pf()
# Executed in 0.08 second(s).
