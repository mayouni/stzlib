# Narrative
# --------
# Get pattern
#
# Extracted from stzmatrextest.ring, block #41.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{size(3x3) & property(identity)}")

? oMx.Pattern()
#--> {size(3x3) & property(identity)}

pf()
