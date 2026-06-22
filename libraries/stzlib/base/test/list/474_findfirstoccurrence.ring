# Narrative
# --------
# FindFirstOccurrence locates an item in a list, matching strictly by
# both value AND type, and returns its 1-based position (0 if absent).
#
# Searching [ 3, 2, 5 ] for the string "2" or the list [ 2 ] returns 0:
# neither matches the integer 2 stored in the list, because Softanza does
# not coerce across types here. Searching for the integer 2 returns 2,
# its position. The reciprocal idiom is Q(item).IsOneOfThese(list): the
# integer 2 is a member (TRUE), but the string "2" and the list [2] are
# not (FALSE), confirming the same type-strict membership semantics.
#
# Extracted from stzlisttest.ring, block #474.

load "../../stzBase.ring"

pr()

? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence("2")
#--> 0

? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence([ 2 ])
#--> 0

? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence( 2 )
#--> 2

? Q(2).IsOneOfThese([ 3, 2, 5 ])
#--> TRUE

? Q("2").IsOneOfThese([ 3, 2, 5 ])
#--> FALSE

? Q([2]).IsOneOfThese([ 3, 2, 5 ])
#--> FALSE

pf()
# Executed in 0.03 second(s).
