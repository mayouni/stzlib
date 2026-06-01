# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #310.

load "../../../stzBase.ring"


o1 = new stzString("123456789")

o1.InsertAfterPositions([3, 6], "_") # or o1.InsertAfterPositions([4, 7], "_")
#--> 123_456_789

pf()
# Executed in 0.03 second(s)
