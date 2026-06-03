# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #228.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "♥", "♥", "♥", 3, 4 ])

? o1.ExtractRange(3, 3)
#--> ["♥", "♥", "♥"]

? o1.Content()
#--> [1, 2, 3, 4]

StopProfiler()

pf()
# Executed in almost 0 second(s) in Ring 1.21
