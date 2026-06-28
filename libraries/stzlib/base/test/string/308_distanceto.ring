# Narrative
# --------
# DistanceTo("6", :StartingAt = 4) counts the chars strictly BETWEEN position 4
# and the next "6" (exclusive: just position 5 -> 1). DistanceToXT counts the two
# bounding positions too (4,5,6 -> 3).
#
# Extracted from stzlisttest.ring, block #308.

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
