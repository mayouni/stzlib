# Narrative
# --------
# Profiling the Duplicates() function --> Reasonable perf up to 30K items!
#
# Extracted from stzlisttest.ring, block #254.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"


pr()

aList = 1:100_000
aList + 1 + "*" + 10:12 + "B" + 2 + 1 + "*" + "A," + 3 + "*" + "B" + 10:12 + "B"

o1 = new stzList(aList)
o1.DuplicatesZ()


pf()
#-->        10 items 	:   0.02 second(s)
#-->       100 items 	:   0.02 second(s)
#-->	   500 items	:   0.03 second(s)
#-->     1_000 items 	:   0.05 second(s)
#-->    10_000 items 	:   1.04 second(s)
#-->    30_000 items	:  10.52 second(s)
#-->    50_000 items	:  60.99 second(s)
#-->   100_000 items	: 220.19 second(s)
