# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #70.

load "../../stzBase.ring"


? StzListOfStringsQ([ "ccc", "bbb", "aaa" ]).SortInAscendingQ().Content()
#--> [ "aaa", "bbb", "ccc" ]

pf()
# Executed in 0.04 second(s)
