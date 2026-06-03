# Narrative
# --------
# 1x1 matrix
#
# Extracted from stzmatrextest.ring, block #45.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{size(1x1)}")

aMatrix = [[42]]
? oMx.Match(aMatrix)
#--> TRUE

pf()
