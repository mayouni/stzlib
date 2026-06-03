# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #759.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzString("abcdefj")

? o1 / 2
#--> [ "abcd", "efj" ]

? o1 % 2
#--> "efj"

pf()
# Executed in 0.03 second(s).
