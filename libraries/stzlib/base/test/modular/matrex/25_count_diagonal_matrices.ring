# Narrative
# --------
# Count diagonal matrices
#
# Extracted from stzmatrextest.ring, block #25.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(diagonal)}")

aMatrices = [
	[[1, 0], [0, 2]],
	[[1, 2], [3, 4]],
	[[5, 0, 0], [0, 6, 0], [0, 0, 7]],
	[[1, 1], [1, 1]]
]

? oMx.CountMatchingMatrices( :In = aMatrices )
#--> 2

pf()
