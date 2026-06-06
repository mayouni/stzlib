# Narrative
# --------
# o1 = new stzString("ab3de6gh9")
#
# Extracted from stzStringTest.ring, block #921.

load "../../stzBase.ring"

pr()

o1 = new stzString("ab3de6gh9")
o1.ReplaceCharsAtPositionsByMany([3, 12, 9], [ "c", "f", "i" ])
? o1.Content()
#--> ERROR MSG: Incorrect param type! panPos must be a list of numbers sorted in ascending.

pf()
