# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #4.

load "../../stzBase.ring"


? random01() # Or ARandomNumberBetween(0, 1)
#--> 0.61

? ARandomNumberBetween(-3.5, 2.8)
#--> -2.45

SetRandomRound(3)
? ARandomNumberLessThan(0.7)
#--> 0.557

pf()
# Executed in almost 0 second(s) in Ring 1.23
