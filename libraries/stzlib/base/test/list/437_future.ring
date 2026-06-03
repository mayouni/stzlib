# Narrative
# --------
# #TODO (future)
#
# Extracted from stzlisttest.ring, block #437.
#ERR Error (R3) : Calling Function without definition: vizfindmany

load "../../stzBase.ring"


pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindMany([ "A", "B", "C", "D" ])
}

# !--> Returns a string like this:

#	  [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#   "A" :  --^----.----.----^----.----^---------.----.----^---------.--
#   "B" :  -------^----.---------.--------------^----.--------------.--
#   "C" :  ------------.---------^-------------------.--------------^--
#   "D" :  ------------^-----------------------------.-----------------

pf()
