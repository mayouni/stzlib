# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #140.
#ERR Error (R14) : Calling Method without definition: show

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendXT( :String, :With = "DE" )
o1.Show()
#--> "ABCDE"

pf()
# Executed in 0.01 second(s) in Ring 1.21
