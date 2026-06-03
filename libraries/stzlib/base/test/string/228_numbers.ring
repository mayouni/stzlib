# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #228.

load "../../stzBase.ring"

pr()

o1 = new stzString("+10,")
? @@( o1.Numbers() )
#--> [ "10" ]

o1 = new stzString("+10,  12;kdjf")
? @@( o1.Numbers() )
#--> [ "10", "12" ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
