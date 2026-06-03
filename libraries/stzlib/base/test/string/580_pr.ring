# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #580.

load "../../stzBase.ring"


o1 = new stzString("<<Go!>>")
? o1.TheseBoundsRemoved("<<", ">>")
#--> "Go!"

pf()
# Executed in 0.06 second(s) in Ring 1.22
