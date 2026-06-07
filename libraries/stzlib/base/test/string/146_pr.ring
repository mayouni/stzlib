# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #146.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("ABCDE")
o1.Shrink( :ToPosition = 3 )
o1.Show()
#--> "ABC"

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.18
