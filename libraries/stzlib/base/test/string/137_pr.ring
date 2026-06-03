# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #137.
#ERR Error (R14) : Calling Method without definition: extendtowith

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendToWith(5, "*")
o1.Show()
#--> "ABC**"

pf()
# Executed in 0.01 second(s) in Ring 1.21
