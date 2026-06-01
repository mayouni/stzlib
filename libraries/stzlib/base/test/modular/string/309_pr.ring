# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #309.

load "../../../stzBase.ring"


o1 = new stzString("123456789")

o1.InsertBefore([4, 7], "_") # or o1.InsertBeforePositions([4, 7], "_")
#--> 123_456_789

? o1.Content()
#--> 123_456_789

pf()
# Executed in 0.03 second(s)
