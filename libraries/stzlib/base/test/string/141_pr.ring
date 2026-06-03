# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #141.
#ERR Error (R14) : Calling Method without definition: show

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendXT( :String, :ToPosition = 5 )
o1.Show()
#--> "ABC  "

pf()
# Executed in 0.05 second(s)
