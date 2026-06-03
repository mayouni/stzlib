# Narrative
# --------
# pr()
#
# Extracted from stzhexnumbertTest.ring, block #4.

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 2, 3, 5 ])
? o1.ArePrimes()
#-->  TRUE

o1 = new stzListOfNumbers([ 2, 4, 5 ])
? o1.ArePrimes()
#-->  FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.21
