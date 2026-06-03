# Narrative
# --------
# (TODO)
#
# Extracted from stzStringTest.ring, block #974.

load "../../stzBase.ring"


? StzStringQ("ABTCADNBBABEFAVCC").VizFindMany([ "A", "T", "V" ])

#--> Returns a string like this:

#	 "ABTCADNVBABEFLVCT"
#  "A" :  ^-.-^--.-^----.-.
#  "T" :  --^----.------.-^
#  "V" :  -------^------^--
#  "X" :  -----------------
