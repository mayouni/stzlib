# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #925.

load "../../stzBase.ring"


o1 = new stzString("ab3de6gh9")
o1.ReplaceCharsAtPositionsByMany([3, 6, 9], [ "c", "f", "i" ])

? o1.Content()
#--> "abcdefghi"

pf()
# Executed in 0.01 second(s).
