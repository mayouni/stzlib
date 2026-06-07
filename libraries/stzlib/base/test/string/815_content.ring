# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #815.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("ABCDEFGH")
o1.CompressUsingBinary("10011011")
? o1.Content()
 #--> ADEGH

pf()
# Executed in 0.01 second(s).
