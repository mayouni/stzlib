# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #282.
#ERR Error (R14) : Calling Method without definition: findnext

load "../../stzBase.ring"

pr()

#                             3             6
o1 = new stzList([ "_", "_", "♥", "_", "_", "♥", "_" ])

? o1.FindFirst("♥")
#--> 3

? o1.FindLast("♥")
#--> 6

? o1.FindNext("♥", :StartingAt = 3)
#--> 6

? o1.FindPrevious("♥", :StartingAt = 6)
#--> 3

? o1.FindNthNext(1, "♥", :StartingAt = 6)
#--> 0

? o1.FindNthNext(1, "♥", :StartingAt = 5)
#--> 6

? o1.FindNthPrevious(2, "♥", :StartingAt = 7)
#--> 3

StopProfiler()

pf()
# Executed in 0.02 second(s) in Ring 1.22
