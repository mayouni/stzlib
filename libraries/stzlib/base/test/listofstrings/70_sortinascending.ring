# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #70.
#ERR Error (R3) : Calling Function without definition: stzlistofstringsq

load "../../stzBase.ring"

pr()

? StzListOfStringsQ([ "ccc", "bbb", "aaa" ]).SortInAscendingQ().Content()
#--> [ "aaa", "bbb", "ccc" ]

pf()
# Executed in 0.04 second(s)
