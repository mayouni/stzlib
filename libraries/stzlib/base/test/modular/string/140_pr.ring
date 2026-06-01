# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #140.

load "../../../stzBase.ring"


o1 = new stzString("ABC")
o1.ExtendXT( :String, :With = "DE" )
o1.Show()
#--> "ABCDE"

pf()
# Executed in 0.01 second(s) in Ring 1.21
