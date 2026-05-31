# Narrative
# --------
# Tall vs wide matrices
#
# Extracted from stzmatrextest.ring, block #6.

load "../../../stzBase.ring"


pr()

oMxTall = new stzMatrex("{shape(tall)}")
oMxWide = new stzMatrex("{shape(wide)}")

aTall = [[1], [2], [3], [4]]
aWide = [[1, 2, 3, 4]]

? oMxTall.Match(aTall)
#--> TRUE

? oMxTall.Match(aWide)
#--> FALSE

? oMxWide.Match(aWide)
#--> TRUE

? oMxWide.Match(aTall)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24
