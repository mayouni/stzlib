# Narrative
# --------
# Combining patterns with OR
#
# Extracted from stzmatrextest.ring, block #33.

load "../../../stzBase.ring"


pr()

oMx1 = new stzMatrex("{property(identity)}")
oMx2 = new stzMatrex("{property(zero)}")

oMxCombined = oMx1.Or_(oMx2)

aIdentity = [[1, 0], [0, 1]]
aZero = [[0, 0], [0, 0]]
aOther = [[1, 2], [3, 4]]

? oMxCombined.Match(aIdentity)
#--> TRUE

? oMxCombined.Match(aZero)
#--> TRUE

? oMxCombined.Match(aOther)
#--> FALSE

pf()
