# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #670.

load "../../stzBase.ring"

pr()

o1 = new stzString("12.4560000")

? o1.HasTrailingChars()
#--> TRUE

? o1.HowManyTrailingChar()
#--> 4

? @@( o1.TrailingChar() )
#--> "0"

? o1.TrailingCharIs("0")
#--> TRUE

pf()
# Executed in 0.01 second(s).
