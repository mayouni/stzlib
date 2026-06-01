# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #815.

load "../../../stzBase.ring"


o1 = new stzString("ABCDEFGH")
o1.CompressUsingBinary("10011011")
? o1.Content()
 #--> ADEGH

pf()
# Executed in 0.01 second(s).
