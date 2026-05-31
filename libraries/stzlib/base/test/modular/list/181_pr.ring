# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #181.

load "../../../stzBase.ring"


o1 = new stzList(1:10)
oListInStr = o1.ToCodeQ()

n1 = oListInStr.FindNth(3, ",")
n2 = oListInStr.FindNth(7, ",")

? oListInStr.Section(n1-1, n2-1)
#--> "3, 4, 5, 6, 7"

pf()
# Executed in 0.03 second(s)
