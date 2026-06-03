# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #137.

load "../../stzBase.ring"


o1 = new stzString("ABC")
o1.ExtendToWith(5, "*")
o1.Show()
#--> "ABC**"

pf()
# Executed in 0.01 second(s) in Ring 1.21
