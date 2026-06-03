# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #58.

load "../../stzBase.ring"


o1 = new stzListOfNumbers([ 8, 10, 14 ])

o1.SubStructManyOneByOne([ 6, 7, 7 ])

? @@( o1.Content() )
#--> [ 2, 3, 7 ]

pf()
# Executed in 0.03 second(s)
