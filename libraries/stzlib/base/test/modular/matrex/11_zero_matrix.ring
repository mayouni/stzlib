# Narrative
# --------
# Zero matrix
#
# Extracted from stzmatrextest.ring, block #11.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(zero)}")

aZero = [
	[0, 0, 0],
	[0, 0, 0],
	[0, 0, 0]
]

aNonZero = [
	[0, 0, 1],
	[0, 0, 0],
	[0, 0, 0]
]

? oMx.Match(aZero)
#--> TRUE

? oMx.Match(aNonZero)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24
