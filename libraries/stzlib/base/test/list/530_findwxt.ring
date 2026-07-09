# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #530.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "a", 2, "b", 3, "c" ])
? o1.FindWF( func x { return isString(x) and Q(x).isLowercase() } )
#--> [2, 4, 6]

StopProfiler()

pf()
# Executed in 0.14 second(s) in Ring 1.21
# Executed in 0.26 second(s) in Ring 1.17
