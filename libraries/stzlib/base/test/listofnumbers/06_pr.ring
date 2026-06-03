# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #6.

load "../../stzBase.ring"


o1 = new stzListOfNumbers([ 1, 5, 7 , 9 ])
? o1.ContainsPositiveAndNegativeNumbers()
#--> FALSE

o1 = new stzListOfNumbers([ -1, -5, -7 , -9 ])
? o1.ContainsPositiveAndNegativeNumbers()
#--> FALSE

o1 = new stzListOfNumbers([ 1, 5, -7 , 9 ])
? o1.ContainsPositiveAndNegativeNumbers()
#--> TRUE

o1 = new stzListOfNumbers([ -1, 5, 7 , -9 ])
? o1.ContainsPositiveAndNegativeNumbers()
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.22
