# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #85.
#ERR Error (R14) : Calling Method without definition: extendto

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendTo(5)
o1.Show()
#--> "ABC  "

pf()
# Executed in 0.01 second(s)
