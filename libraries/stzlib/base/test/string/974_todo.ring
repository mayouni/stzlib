# Narrative
# --------
# (TODO)
#
# Extracted from stzStringTest.ring, block #974.
#ERR Error (R14) : Calling Method without definition: vizfindmany

load "../../stzBase.ring"

pr()

? StzStringQ("ABTCADNBBABEFAVCC").VizFindMany([ "A", "T", "V" ])

#--> Returns a string like this:

#	 "ABTCADNVBABEFLVCT"
#  "A" :  ^-.-^--.-^----.-.
#  "T" :  --^----.------.-^
#  "V" :  -------^------^--
#  "X" :  -----------------

pf()
