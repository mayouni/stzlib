# Narrative
# --------
# (TODO)
#
# Extracted from stzStringTest.ring, block #975.

load "../../stzBase.ring"


? StzStringQ("ABTCADNBBABEFAVCC").VizFindManyXT("A")

#--> Returns a string like this:

#	  1..4..7..0..3..6.
#	 "ABTCADNVBABEFLVCT"
#  "A" :  ^-.-^--.-^----.-. (3)
#  "T" :  --^----.------.-^ (2)
#  "V" :  -------^------^-- (2)
#  "X" :  ----------------- (0)
