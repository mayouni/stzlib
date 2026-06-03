# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #828.

load "../../stzBase.ring"

pr()

o1 = new stzString("  lots   of    whitespace  ")

? o1.Trimmed()
#--> "lots   of    whitespace"

? o1.SimplifyQ().UPPERcased()
#--> "LOTS OF WHITESPACE"

pf()
# Executed in 0.01 second(s).
