# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #5.
#ERR Error (R11) : Error in class name, class not found: stzwalker

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 1, 2, 3, 4, 5 ])
? @@( o1.Walker().Walkables() )
#--> [ 1, 2, 3, 4, 5 ]

o1 = new stzListOfNumbers([ 1, 2, 5, 6, 9, 10 ])
? @@( o1.Walker().Walkables() )
#--> [ 1, 2, 5, 6, 9, 10 ]

pf()
