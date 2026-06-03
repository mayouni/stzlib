# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #909.

load "../../stzBase.ring"


o1 = new stzString("--R--I--N--G--")
? o1.FindMany([ "R", "I", "N", "G" ])
#--> [ 3, 6, 9, 12 ]

pf()
# Executed in 0.01 second(s).
