# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #149.
#ERR Error (R14) : Calling Method without definition: findwxt

load "../../stzBase.ring"

pr()

o1 = new stzString("...♥...♥...")
? o1.FindWXT('@char = "♥"')
#--> [4, 8]

pf()
# Executed in 0.25 second(s) in Ring 1.21
# Executed in 1.69 second(s) in Ring 1.19
