# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #15.

load "../../stzBase.ring"

pr()

o1 = new stzNumber("1234567.1234567")

? o1.Integers()
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

? o1.IntergersQRT(:stzListOfNumbers).Sum() + NL # Misspelled, but works!
#--> 28

? o1.Decimals()
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

? o1.DecimalsQRT(:stzListOfNumbers).Sum()
#--> 28

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.11 second(s) in ring 1.18
