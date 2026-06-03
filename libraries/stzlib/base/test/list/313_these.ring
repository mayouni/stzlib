# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #313.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzList([1,2,3,4,5])
? o1 - These([3,5])
#--> [ 1, 2, 4 ]

pf()
# Executed in almost 0 second(s).
