# Narrative
# --------
# Diagonal matrix
#
# Extracted from stzmatrextest.ring, block #10.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(diagonal)}")

aDiagonal = [
	[5, 0, 0],
	[0, 3, 0],
	[0, 0, 7]
]

aNonDiagonal = [
	[5, 1, 0],
	[0, 3, 0],
	[0, 0, 7]
]

? oMx.Match(aDiagonal)
#--> TRUE

? oMx.Match(aNonDiagonal)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24
