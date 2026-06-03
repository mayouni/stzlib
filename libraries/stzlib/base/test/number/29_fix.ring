# Narrative
# --------
# FIX
#
# Extracted from stznumbertest.ring, block #29.

load "../../stzBase.ring"


pr()

//? StzListOfListsQ([ [ "a", "b", "c" ], [ 1, "b", 2, "c" ] ]).CommonItems()
#--> [ "b", "c" ]

? CommonItems([ :Between = [ "a", "b", "c" ], :And = [ 1, "b", 2, "c" ] ])

pf()
# Executed in 0.04 second(s) in Ring 1.19
# Executed in 0.07 second(s) in Ring 1.17
