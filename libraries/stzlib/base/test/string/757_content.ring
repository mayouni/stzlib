# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #757.
#ERR Error (R14) : Calling Method without definition: multiplyby

load "../../stzBase.ring"

pr()

o1 = new stzString("a")
o1.MultiplyBy([ "b", "c", "d" ])
? o1.Content() #--> "abacad"

pf()
# Executed in 0.01 second(s).
