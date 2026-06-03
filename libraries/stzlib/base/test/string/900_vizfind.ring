# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #900.
#ERR Error (R14) : Calling Method without definition: vizfind

load "../../stzBase.ring"

pr()

? StzStringQ("ABTCADNBBABEFACCC").VizFind("A")
#--> 
#	"ABTCADNBBABEFACCC"
#	 ^---^----^---^---

pf()
# Executed in 0.06 second(s).
