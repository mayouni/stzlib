# Narrative
# --------
# First matching matrix
#
# Extracted from stzmatrextest.ring, block #26.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(identity)}")

aMatrices = [
	[[1, 2], [3, 4]],
	[[1, 0], [0, 1]],
	[[5, 6], [7, 8]]
]

? @@( oMx.FirstMatchingMatrixIn(aMatrices) )
#--> [ [1, 0], [0, 1] ]

? oMx.FindFirstMatchingMatrix(:In = aMatrices)
#--> 2

pf()
