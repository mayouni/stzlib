# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #758.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzString("a")
? o1 * [ "b", "c", "d" ]
#--> abacad

pf()
# Executed in 0.01 second(s).
