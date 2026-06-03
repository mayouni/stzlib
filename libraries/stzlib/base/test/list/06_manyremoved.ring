# Narrative
# --------
# ///
#
# Extracted from stzlisttest.ring, block #6.
#ERR Error (R14) : Calling Method without definition: manyremoved

load "../../stzBase.ring"


pr()

? Q(1:10).ManyRemoved([ 3, 7, 9 ])
#--> [ 1, 2, 4, 5, 6, 8, 10 ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
