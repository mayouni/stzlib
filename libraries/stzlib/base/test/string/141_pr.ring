# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #141.

load "../../stzBase.ring"


o1 = new stzString("ABC")
o1.ExtendXT( :String, :ToPosition = 5 )
o1.Show()
#--> "ABC  "

pf()
# Executed in 0.05 second(s)
