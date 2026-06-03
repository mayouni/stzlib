# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #230.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "♥", 4, "♥", 6, "♥" ])

? o1.ExtractPrevious("♥", :StartingAt = 6)
#--> "♥"

? @@( o1.Content() )
#--> [ 1, 2, 4, "♥", 6, "♥" ]

StopProfiler()

pf()
# Executed in almost 0 second(s).
