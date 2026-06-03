# Narrative
# --------
# Exact element value
#
# Extracted from stzmatrextest.ring, block #16.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{element(5)}")

aAllFives = [
	[5, 5, 5],
	[5, 5, 5]
]

aMixed = [
	[5, 5, 5],
	[5, 3, 5]
]

? oMx.Match(aAllFives)
#--> TRUE

? oMx.Match(aMixed)
#--> FALSE

pf()

#=====================#
#  COMBINED PATTERNS  #
#=====================#
