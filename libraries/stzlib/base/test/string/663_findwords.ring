# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #663.
#ERR Error (R14) : Calling Method without definition: findwords

load "../../stzBase.ring"

pr()

o1 = new stzString("in search of lost time, all the time")
? @@( o1.FindWords() )
#--> [ 1, 4, 11, 14, 19, 25, 29, 33 ]

pf()
# Executed in 0.05 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.17
