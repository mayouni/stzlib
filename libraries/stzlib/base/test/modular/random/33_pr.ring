# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #33.

load "../../../stzBase.ring"


? random(-10) # Standard Ring function returning NULL
#--> ""

? StzRandom(-10) + NL
#--> -5

? SomeRandomNumbersBetween(-10, -1)
#--> [ -10, -10, -4 ]

? SomeRandomNumbersBetweenU(-10, -1)
#--> [ -10, -7, -3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.20
