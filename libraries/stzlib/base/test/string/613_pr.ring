# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #613.

load "../../stzBase.ring"


? Q("ring").Contains("ring")
#--> TRUE

? Q("").Contains('')
#--> FALSE

? Q([ 12, 66 ]).IsIncludedIn([ 12, 66 ])
#--> FALSE

? Q([ 12, 66]).AreInCludedIn([ 12, 66 ])
#--> TRUE

? Q([]).Contains([])
#--> FALSE

? Q([ 1, [], 3 ]).Contains([])
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.19
# Executed in 0.03 second(s) in Ring 1.18
