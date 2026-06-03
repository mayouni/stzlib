# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #27.
#ERR Error (C9) : Brackets ']' is missing

load "../../stzBase.ring"

pr()

? @@( Association([ [ :one, :two, :three ], s[1, 2, 3] ]) )
#--> [ [ "one", 1 ], [ "two", 2 ], [ "three", 3 ] ]

pf()
# Executed in 0.05 second(s)
