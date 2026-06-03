# Narrative
# --------
# NOT identity
#
# Extracted from stzmatrextest.ring, block #22.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{@!property(identity)}")

aIdentity = [
	[1, 0, 0],
	[0, 1, 0],
	[0, 0, 1]
]

aDiagonal = [
	[2, 0, 0],
	[0, 3, 0],
	[0, 0, 4]
]

? oMx.Match(aIdentity)
#--> FALSE

? oMx.Match(aDiagonal)
#--> TRUE

pf()
