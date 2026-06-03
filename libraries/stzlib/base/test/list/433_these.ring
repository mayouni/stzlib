# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #433.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzList([ "fa", "bo" , "wy" , "wo" ])
? @@( o1 - These([ "bo", "wo" ]) )
#--> [ "fa", "wy" ]

pf()
# Executed in almost 0 second(s).
