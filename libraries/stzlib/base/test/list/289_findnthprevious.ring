# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #289.
#ERR Error (R21) : Using operator with values of incorrect type

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "A":"C", 5, 7, 8, 9, "A":"C" ])
? o1.FindNthPrevious(2, "A":"C", :StartingAt = 7)
#--> 0

StopProfiler()

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.22 second(s) in Ring 1.20
