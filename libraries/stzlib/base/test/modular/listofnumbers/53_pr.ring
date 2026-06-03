# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #53.

load "../../../stzBase.ring"


o1 = new stzListOfNumbers([ 1, 2, 3, 4, 5, 6, 7, 8, 9 ])

o1.Cumulate()

? @@( o1.Content() )
#--> [ 1, 2, 5, 9, 14, 20, 27, 35, 44 ]

pf()
# Executed in 0.03 second(s)
