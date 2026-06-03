# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #33.

load "../../stzBase.ring"

pr()

? @@( ListsMerge([ [3, 5], [7, [8]] ]) )
#--> [ 3, 5, 7, [ 8 ] ]

pf()
# Executed in 0.03 second(s)
