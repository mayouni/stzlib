# Narrative
# --------
# SortInDescendingQ is the fluent (Q) form of SortInDescending,
# returning the same stzListOfStrings so the chain can keep
# pipelining. Here we sort ["aaa","bbb","ccc"] in descending
# alphabetical order and Content() unwraps the list.
#
# Extracted from stzlistofstringstest.ring, the sort-descending
# block.
#ERR Error (R3) : Calling Function without definition: stzlistofstringsq

load "../../stzBase.ring"

pr()

? StzListOfStringsQ([ "aaa", "bbb", "ccc" ]).SortInDescendingQ().Content()
#--> [ "ccc", "bbb", "aaa" ]

pf()
