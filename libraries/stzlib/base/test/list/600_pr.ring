# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #600.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

# The distribution of the items of a list can be made directly using
# the "/" operator on the list object:

o1 = new stzList( L(' "♥1" : "♥6" ' ) ) # or simply o1 = LQ(' "♥1" : "♥6" ')
? @@( o1 / 6 )
#-->[ [ "♥1" ], [ "♥2" ], [ "♥3" ], [ "♥4" ], [ "♥5" ], [ "♥6" ] ]

? o1 / 8
#--> Error message:
#--> Incorrect value! n must be between 0 and 6 (the size of the list)

#NOTE
#--> The beneficiary items can be of any type. In practice, they are
# strings and hence the returned result is a hashlist.

pf()
# Executed in 0.08 second(s)
