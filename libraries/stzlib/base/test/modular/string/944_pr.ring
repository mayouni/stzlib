# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #944.

load "../../../stzBase.ring"


o1 = new stzString("SOFTANZA")
o1.InsertAfterPositions([ 2, 4, 6, 8 ], " ")
? o1.Content()
#--> "SO FT AN ZA"

pf()
# Executed in 0.01 second(s).
