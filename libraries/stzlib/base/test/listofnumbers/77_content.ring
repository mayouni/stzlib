# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #77.

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 4, 7, 36, 9, 20 ])
o1.AddToEachW( 1, :Where = '{ Q(This[@i]).IsDividableBy(4) and This[@i] <= 20 }' )

? @@(o1.Content())
#--> [ 5, 21 ]

pf()
# Executed in 0.17 second(s)
