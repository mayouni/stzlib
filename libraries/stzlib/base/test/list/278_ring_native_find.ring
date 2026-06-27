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

? StzFindFirst([ "A", "B", [ 1, 2, 3 ], "C" ], [ 1, 2, 3 ])
#ERROR! StzFindFirst() must embrace the same format as ring find()
# where the list is first item and the item to find is second
# It also must be implemented efficiently and entirely using the
# engine. Do not duplicate the implementation cross gloabl and object.
# Implement it in one side and use it consustently!


pf()
