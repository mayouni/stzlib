# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #668.

load "../../stzBase.ring"

pr()

o1 = new stzString(".....mmMm")

? o1.HasTrailingChars()
#--> FALSE

? @@( o1.TrailingChar() ) + NL
#--> ""

? o1.HasTrailingCharsCS(:CaseSensitive = FALSE)
#--> TRUE

? o1.TrailingCharCS(FALSE)
#--> "m"

pf()
# Executed in 0.01 second(s).
