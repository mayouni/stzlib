# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #459.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c" ])
? @@( o1 - These([ "b", "a", "c" , "q" ]) )
#--> []

pf()
# Executed in almost 0 second(s).
