# Narrative
# --------
# @perf
#
# Extracted from stzlisttest.ring, block #14.

load "../../stzBase.ring"


pr()

# PERFORMANCE TIP - FOR LARGE LISTS: Using Association() function directly
# is better (4X) than using it through a stzListOfLists object

Association([ 1 : 1_000_000, 1_000_001 : 2_000_000 ])
# Executed in 3.41 second(s)

StzListOfListsQ([ 1 : 1_000_000, 1_000_001 : 2_000_000 ]).Associated()
# Executed in 11.12 second(s)

pf()
# Executed in 11.80 second(s)
