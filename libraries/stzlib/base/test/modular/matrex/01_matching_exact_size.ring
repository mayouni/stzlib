# Narrative
# --------
# Matching exact size
#
# Extracted from stzmatrextest.ring, block #1.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{Size(3x3)}")

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aMatrix)
#--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.24
