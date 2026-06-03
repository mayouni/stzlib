# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #120.

load "../../stzBase.ring"


o1 = new stzString("aa***aa**aa***aa")
? o1.IsBoundedByCS("aa", TRUE)
#--> TRUE

pf()
# Executed in 0.03 second(s)
