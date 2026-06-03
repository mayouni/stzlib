# Narrative
# --------
# Empty pattern
#
# Extracted from stzmatrextest.ring, block #44.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{}")

aMatrix = [[1, 2], [3, 4]]
? oMx.Match(aMatrix)
#--> TRUE

pf()
