# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #943.

load "../../../stzBase.ring"


o1 = new stzString("SOFTANZA")
o1.InsertBeforePositions([ 2, 4, 6, 8 ], " ")
? o1.Content()
#--> S OF TA NZ A

pf()
# Executed in 0.01 second(s).
