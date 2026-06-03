# Narrative
# --------
# SortInDescendingQ is the fluent (Q) form of SortInDescending,
# returning the same stzListOfStrings so the chain can keep
# pipelining. Here we sort ["aaa","bbb","ccc"] in descending
# alphabetical order and Content() unwraps the list.
#
# Extracted from stzlistofstringstest.ring, the sort-descending
# block.

load "../../stzBase.ring"


? StzListOfStringsQ([ "aaa", "bbb", "ccc" ]).SortInDescendingQ().Content()
#--> [ "ccc", "bbb", "aaa" ]
