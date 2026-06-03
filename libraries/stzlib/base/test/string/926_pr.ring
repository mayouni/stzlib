# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #926.

load "../../stzBase.ring"


o1 = new stzString("...456...012...678..")
o1.ReplaceSectionsByMany([ [ 4, 6], [10, 12], [16, 18] ], ["A", "BB", "CCC"])
? o1.Content()
#--> ...A...BB...CCC..

pf()
# Executed in 0.01 second(s).
