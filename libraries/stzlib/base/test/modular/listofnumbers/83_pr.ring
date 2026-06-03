# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #83.

load "../../../stzBase.ring"


o1 = new stzListOfNumbers(1:8)
o1.SubStructFromEach(2)
? ListToCode( o1.Content() )
#--> [ -1, 0, 1, 2, 3, 4, 5, 6 ]

pf()
# Executed in 0.03 second(s)
