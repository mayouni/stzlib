# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #85.

load "../../../stzBase.ring"


o1 = new stzListOfNumbers(1:8)

? o1.ContainsADividableNumberBy(2) + NL
#--> TRUE

? @@( o1.DividableNumbersBy(2) )
#--> [ 2, 4, 6, 8 ]

pf()
# Executed in 0.04 second(s)
