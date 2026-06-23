# Narrative
# --------
# #ring
#
# Extracted from stzlisttest.ring, block #278.

load "../../stzBase.ring"


pr()

? find([ "A", "B", [ 1, 2, 3 ], "C" ], "C")
#--> 4

? find([ "A", "B", [ 1, 2, 3 ], "C" ], [ 1, 2, 3 ])
#--> ERROR: Bad parameter type!

pf()
