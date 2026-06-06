# Narrative
# --------
# /*-------------
#
# Extracted from stzStringTest.ring, block #967.

load "../../stzBase.ring"


pr()

o1 = new stzString("123---789---")
o1.ReplaceSectionsByMany([ [1, 3], [7, 9] ], [ "^^^", "vvv" ])
? o1.Content()
#--> ^^^---vvv---

pf()
# Executed in 0.01 second(s).
