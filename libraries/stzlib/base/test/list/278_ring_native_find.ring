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
#--> 0

? StzFindFirst([ 1, 2, 3 ], :In = [ "A", "B", [ 1, 2, 3 ], "C" ])
#--> 3

pf()
# Executed in almost 0 second(s) in Ring 1.27
