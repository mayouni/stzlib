# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #822.

load "../../stzBase.ring"


o1 = new stzString("Ring programming language")

anPos = o1.Find("in")
? anPos
#--> [ 2, 14 ]

o1.InsertBeforePositions(anPos, "_")
? o1.Content()
#--> R_ing programm_ing language

pf()
# R_ing programm_ing language
