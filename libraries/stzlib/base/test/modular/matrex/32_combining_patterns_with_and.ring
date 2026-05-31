# Narrative
# --------
# Combining patterns with AND
#
# Extracted from stzmatrextest.ring, block #32.

load "../../../stzBase.ring"


pr()

oMx1 = new stzMatrex("{shape(square)}")
oMx2 = new stzMatrex("{property(symmetric)}")

oMxCombined = oMx1.And_(oMx2)

aValid = [
	[1, 2, 3],
	[2, 4, 5],
	[3, 5, 6]
]

aInvalid = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMxCombined.Match(aValid)
#--> TRUE

? oMxCombined.Match(aInvalid)
#--> FALSE

pf()
