# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #224.

load "../../../stzBase.ring"


o1 = new stzList([ "_", "A", "B", "C" ])

? o1.ExtractFirst("_") + NL

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20
