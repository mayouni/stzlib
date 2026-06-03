# Narrative
# --------
# NOT symmetric
#
# Extracted from stzmatrextest.ring, block #21.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{@!property(symmetric)}")

aSymmetric = [
	[1, 2],
	[2, 3]
]

aAsymmetric = [
	[1, 2],
	[3, 4]
]

? oMx.Match(aSymmetric)
#--> FALSE

? oMx.Match(aAsymmetric)
#--> TRUE

pf()
