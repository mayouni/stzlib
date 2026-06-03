# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #79.

load "../../stzBase.ring"


o1 = new stzListOfNumbers([ 5, 15, 25, 35 ])
o1.DivideEachByW( 5, :Where = '{ @number > 20 }' )
? @@(o1.Content())
#--> [ 5, 7 ]

pf()
# Executed in 0.11 second(s)
