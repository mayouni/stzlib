# Narrative
# --------
#
# NOTE (audit, 2026-07-04): DEFERRED -- VizFindMany labeled-rails display -- the archive block is a self-declared TODO whose expected output is aspirational AND garbled (different text, phantom "X" row). The current stacked-blocks display works; the labeled-rail format needs a real spec first.
# (TODO)
#
# Extracted from stzStringTest.ring, block #974.

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
