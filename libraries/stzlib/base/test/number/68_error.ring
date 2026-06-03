# Narrative
# --------
# ERROR
#
# Extracted from stznumbertest.ring, block #68.
#ERR Error (R14) : Calling Method without definition: tobinaryformwithoutprefix

load "../../stzBase.ring"

pr()

o1 = new stzNumber("12500")
? o1.ToBinaryFormwithoutPrefix()

pf()
