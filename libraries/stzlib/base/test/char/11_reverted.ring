# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #11.
#ERR Error (R14) : Calling Method without definition: reverted

load "../../stzBase.ring"

pr()

o1 = new stzChar("M")
? o1.Reverted()
#--> Ɯ

o1 = new stzChar("Ɯ")
? o1.Reverted()
#--> M

pf()
# Executed in 0.04 second(s) in Ring 1.23
# Executed in 0.08 second(s) in Ring 1.20
