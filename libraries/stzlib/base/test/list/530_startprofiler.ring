# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #530.

load "../../stzBase.ring"


o1 = new stzList([ 1, "a", 2, "b", 3, "c" ])
? o1.FindWXT('{ isString(@item) and Q(@item).isLowercase() }')
#--> [2, 4, 6]

StopProfiler()
# Executed in 0.14 second(s) in Ring 1.21
# Executed in 0.26 second(s) in Ring 1.17
