# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #667.
#ERR Error (R14) : Calling Method without definition: removecharswxt

load "../../stzBase.ring"

pr()

o1 = new stzString("125.450")

o1.RemoveCharsWXT('{ @char = "2" }')
? o1.Content()
#--> "15.450"

pf()
# Executed in 0.14 second(s).
