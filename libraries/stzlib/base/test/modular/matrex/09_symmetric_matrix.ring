# Narrative
# --------
# Symmetric matrix
#
# Extracted from stzmatrextest.ring, block #9.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(symmetric)}")

aSymmetric = [
	[1, 2, 3],
	[2, 4, 5],
	[3, 5, 6]
]

aAsymmetric = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aSymmetric)
#--> TRUE

? oMx.Match(aAsymmetric)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24
