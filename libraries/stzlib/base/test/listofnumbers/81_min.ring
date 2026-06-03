# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #81.

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 12, 10, 98, 3, 23, 98, 7 ])

? o1.Min()
#--> 3

? o1.FindMin() + NL
#--> 4

? o1.Max()
#--> 98

? o1.FindMax()
#--> 3

pf()
# Executed in 0.03 second(s)
