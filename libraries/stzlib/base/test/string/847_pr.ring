# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #847.

load "../../stzBase.ring"


o1 = new stzString("10011033001")

? o1.IsMadeOf([ "1", "0", "3" ])
#--> TRUE

? o1.IsMadeOf([ "1", "0", :and = "3" ])
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22
