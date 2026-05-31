# Narrative
# --------
# Elements from set
#
# Extracted from stzmatrextest.ring, block #15.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{element({0;1})}")

aBinary = [
	[1, 0, 1],
	[0, 1, 0],
	[1, 1, 0]
]

aNonBinary = [
	[1, 0, 2],
	[0, 1, 0],
	[1, 1, 0]
]

? oMx.Match(aBinary)
#--> TRUE

? oMx.Match(aNonBinary)
#--> FALSE

pf()
