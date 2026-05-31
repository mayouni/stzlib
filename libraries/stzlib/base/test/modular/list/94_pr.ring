# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #94.

load "../../../stzBase.ring"


o1 = new stzList([ 1, "r_INg", 2, "R_ng", 3, "R_ING" ])
o1.StringifyLowercaseAndReplaceXT("_", :With = AHeart())
o1.Show()
#--> [ [ "1", "r♥ing", "2", "r♥ng", "3", "r♥ing" ], [ 2, 4, 6 ], [ ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.03 second(s) in Ring 1.19
