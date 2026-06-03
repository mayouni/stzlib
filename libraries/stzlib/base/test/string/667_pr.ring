# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #667.

load "../../stzBase.ring"


o1 = new stzString("125.450")

o1.RemoveCharsWXT('{ @char = "2" }')
? o1.Content()
#--> "15.450"

pf()
# Executed in 0.14 second(s).
