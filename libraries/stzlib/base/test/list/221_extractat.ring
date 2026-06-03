# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #221.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "_", "B", "C" ])
? o1.ExtractAt(2) + NL
#--> "_"

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20
