# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #557.

load "../../stzBase.ring"


o1 = new stzString("12*A*33*A*")

? o1.Sections([ 1:2, 6:7 ])
#--> [ "12", "33" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
