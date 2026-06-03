# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #474.
#ERR Error (R14) : Calling Method without definition: findfirstoccurrence

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
