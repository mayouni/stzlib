# Narrative
# --------
# Matching wrong size
#
# Extracted from stzmatrextest.ring, block #2.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{size(2x2)}")

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aMatrix)
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.24
