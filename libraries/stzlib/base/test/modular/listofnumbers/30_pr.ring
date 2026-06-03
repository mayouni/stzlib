# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #30.

load "../../../stzBase.ring"


o1 = new stzListOfNumbers(1:5)
? o1.NumbersGreaterThan(3)
#--> [4, 5]

? o1.NumbersLessThan(3)
#--> [1, 2]

? o1.NumbersOtherThan(3)
#--> [1, 2, 4, 5]

pf()
# Executed in 0.04 second(s)
