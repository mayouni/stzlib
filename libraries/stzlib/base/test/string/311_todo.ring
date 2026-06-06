# Narrative
# --------
# TODO
#
# Extracted from stzStringTest.ring, block #311.

load "../../stzBase.ring"


pr()

o1 = new stzString("123456789")

o1.InsertAfterEachNCharsXT(3, :StartingFrom = :End)
? o1.Content()
#--> 123_456_789

pf()
# Executed in 0.03 second(s)
