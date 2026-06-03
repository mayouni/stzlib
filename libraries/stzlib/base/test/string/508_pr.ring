# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #508.

load "../../stzBase.ring"


o1 = new stzString("ab_cd_ef_gh")
? o1.FindFirst("_")
#--> 3

? o1.FindFirstST("*", :StartingAt = 4)
#--> 0

? o1.FindFirstST("_", :StartingAt = 3)
#--> 3

? o1.FindLast("_")
#--> 9

? o1.FindLast("*")
#--> 0

? o1.FindNth(2,"_")
#--> 6

pf()
# Executed in 0.01 second(s) in Ring 1.22
