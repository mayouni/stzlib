# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #845.
#ERR Error (R14) : Calling Method without definition: islatin

load "../../stzBase.ring"

pr()

o1 = new stzString("Ⅱ")
? o1.IsLatin()
#--> TRUE

o1 = new stzChar("Ⅱ")
? o1.IsRomanNumber()
#--> TRUE

pf()
# Executed in 0.04 second(s).
