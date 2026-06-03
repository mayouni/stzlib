# Narrative
# --------
# (TODO)
#
# Extracted from stzStringTest.ring, block #975.
#ERR Error (R14) : Calling Method without definition: vizfindmanyxt

load "../../stzBase.ring"

pr()

? StzStringQ("ABTCADNBBABEFAVCC").VizFindManyXT("A")

#--> Returns a string like this:

#	  1..4..7..0..3..6.
#	 "ABTCADNVBABEFLVCT"
#  "A" :  ^-.-^--.-^----.-. (3)
#  "T" :  --^----.------.-^ (2)
#  "V" :  -------^------^-- (2)
#  "X" :  ----------------- (0)

pf()
