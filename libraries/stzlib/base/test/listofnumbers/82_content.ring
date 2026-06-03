# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #82.

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers(1:8)
o1.AddToEveryNumber(2)
? ListToCode( o1.Content() )
#--> [ 3, 4, 5, 6, 7, 8, 9, 10 ]

pf()
# Executed in 0.03 second(s)
