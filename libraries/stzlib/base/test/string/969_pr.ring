# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #969.

load "../../stzBase.ring"


o1 = new stzString("123---78--")
o1.ReplaceSectionsByMany([ [1, 3], [7,8] ], [ "*", "~" ] )
? o1.Content()
# *---~--

pf()
# Executed in 0.01 second(s).
