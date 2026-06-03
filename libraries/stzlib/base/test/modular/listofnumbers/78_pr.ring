# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #78.

load "../../../stzBase.ring"


o1 = new stzListOfNumbers([ 4, 14, 24, 34 ])
o1.SubStructFromEachW( 10, :Where = '{ @number > 20 }' )
? @@(o1.Content())
#--> [ 14, 24 ]

pf()
# Executed in 0.11 second(s)
