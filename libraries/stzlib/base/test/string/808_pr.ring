# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #808.

load "../../stzBase.ring"


o1 = new stzString("Ringos Ringos Ringos")
o1.RemoveAll("os")
? o1.Content()
#--> Ring Ring Ring

pf()
# Executed in 0.01 second(s).
