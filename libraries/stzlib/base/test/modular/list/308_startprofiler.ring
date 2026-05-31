# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #308.

load "../../../stzBase.ring"


o1 = new stzString("---456---")

? o1.DistanceTo("6", :StartingAt = 4)
#--> 1

? o1.DistanceToXT("6", :StartingAt = 4)
#--> 3

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.22
