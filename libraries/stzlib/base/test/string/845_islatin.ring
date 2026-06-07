# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #845.
#ERR exit 1: Line 98 Bad parameters value, error in length!

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
