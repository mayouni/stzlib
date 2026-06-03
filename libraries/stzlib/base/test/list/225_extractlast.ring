# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #225.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C", "_" ])

? o1.ExtractLast("_") + NL
#--> "_"

? o1.Content()
#--> ["A", "B", "C"]

StopProfiler()

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20
