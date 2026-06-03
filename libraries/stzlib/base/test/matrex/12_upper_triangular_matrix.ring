# Narrative
# --------
# Upper triangular matrix
#
# Extracted from stzmatrextest.ring, block #12.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(upper)}")

aUpper = [
	[1, 2, 3],
	[0, 4, 5],
	[0, 0, 6]
]

aLower = [
	[1, 0, 0],
	[2, 3, 0],
	[4, 5, 6]
]

? oMx.Match(aUpper)
#--> TRUE

? oMx.Match(aLower)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24
