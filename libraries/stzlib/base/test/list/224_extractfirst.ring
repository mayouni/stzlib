# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #224.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzList([ "_", "A", "B", "C" ])

? o1.ExtractFirst("_") + NL

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20
