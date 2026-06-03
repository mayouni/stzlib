# Narrative
# --------
# o1 = new stzString("123---789---")
#
# Extracted from stzStringTest.ring, block #966.

load "../../stzBase.ring"

o1.ReplaceSectionsByMany([ [1, 3], [7, 9] ], "^")
? o1.Content()
#--> ERROR MESSAGE: Incorrect param type! pacSubStr must be a list.
