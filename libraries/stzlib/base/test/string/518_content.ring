# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #518.
#ERR Error (R14) : Calling Method without definition: swap

load "../../stzBase.ring"

pr()

o1 = new stzString("TWO, ONE, THREE!")
o1.Swap("TWO", :And = "ONE") # Or SwapSubStrings()
? o1.Content()
#--> ONE, TWO, THREE!

pf()
# Executed in 0.02 second(s) in Ring 1.22
