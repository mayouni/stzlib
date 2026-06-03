# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #320.
#ERR Error (R14) : Calling Method without definition: howmanyst

load "../../stzBase.ring"

pr()

o1 = new stzString("123456♥..♥♥")
? o1.HowManyST("♥", :StartingAt = 6) # Or NumberOfOuccurrenceST() or CountST()
#--> 3

o1 = new stzList( @Chars("123456♥..♥♥") )
? o1.HowManyST("♥", :StartingAt = 6)
#--> 3

pf()
# Executed in 0.01 second(s) in Ring 1.21
