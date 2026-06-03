# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #73.
#ERR Error (R3) : Calling Function without definition: stzcharerror

load "../../stzBase.ring"

pr()

o1 = new stzChar("X")
? o1.AsciiCode() #--> 88

o1 = new stzChar("س")
? o1.AsciiCode()
#--> Can't get ASCII code for this character!

pf()
