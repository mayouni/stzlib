# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #145.

load "../../stzBase.ring"

pr()

o1 = new stzString("ABC")
o1.ExtendXT( :ToPosition = 5, :WithCharsIn = [ "D", "E" ])
o1.Show()
#--> "ABCDED"

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.18
