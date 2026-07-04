# Narrative
# --------
#
# NOTE (audit, 2026-07-04): DEFERRED -- VizFindManyXT with counts -- same aspirational-TODO family as 974.
# (TODO)
#
# Extracted from stzStringTest.ring, block #975.

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
