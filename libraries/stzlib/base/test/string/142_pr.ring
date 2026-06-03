# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #142.
#ERR Error (R14) : Calling Method without definition: show

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :With = :CharsRepeated )
o1.Show()
#--> "ABCAB"

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.18
