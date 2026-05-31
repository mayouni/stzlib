# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #465.

load "../../../stzBase.ring"


? StzStringQ("ab []    cd").Simplified()
#--> ab [] cd

? Q(list2code([ "a", [ [] ], "b" ])).Simplified()
#--> [ "a",[ [ ] ],"b" ]

pf()
# Executed in 0.01 second(s).
