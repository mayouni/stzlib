# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #93.

load "../../../stzBase.ring"


o1 = new stzString("")

? @@( o1.FindSSZ("", -1, 0) ) # FindInSection()
#--> []

? @@( o1.FindSSZZ("", -1, 0) )
#-->  []

pf()
# Executed in 0.02 second(s) in Ring 1.22
