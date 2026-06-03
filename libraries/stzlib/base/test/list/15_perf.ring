# Narrative
# --------
# @perf
#
# Extracted from stzlisttest.ring, block #15.

load "../../stzBase.ring"


pr()

# PERFORMANCE TIP - FOR LARGE LISTS: Using Merge() function directly
# can be better than using it through a stzListOfLists object

Merge([ 1 : 1_000_000, 1_000_001 : 2_000_000 ])
# Executed in 1.19 second(s)

StzListOfListsQ([ 1 : 1_000_000, 1_000_001 : 2_000_000 ]).Merged()
# Executed in 1.93 second(s)

pf()
# Executed in 3.15 second(s)
