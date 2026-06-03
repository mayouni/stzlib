# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #458.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c" ])
? @@( o1 - These([ "b", "a" ]))
#--> [ "c" ]

pf()
# Executed in almost 0 second(s).
