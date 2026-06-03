# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #34.

load "../../stzBase.ring"

pr()

? random(0)
#--> 0

? StzRandom(0) + NL
#--> 0

# Generate 0s as random numbers:

? NRandomNumbersIn(5, 0:3)
#--> [ 0, 3, 1, 1, 0 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20
