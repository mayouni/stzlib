# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #139.
#ERR Error (R14) : Calling Method without definition: extendtowithcharsin

load "../../stzBase.ring"

pr()

o1 = new stzString("123")
o1.ExtendToWithCharsIn( 8, "1":"3" )
o1.Show()
#--> "12312312"

pf()
# Executed in 0.01 second(s) in Ring 1.21
