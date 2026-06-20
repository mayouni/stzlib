# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #308.
#ERR Error (R14) : Calling Method without definition: distanceto

load "../../stzBase.ring"

pr()

o1 = new stzString("---456---")

? o1.DistanceTo("6", :StartingAt = 4)
#--> 1

? o1.DistanceToXT("6", :StartingAt = 4)
#--> 3

StopProfiler()

pf()
# Executed in 0.01 second(s) in Ring 1.22
