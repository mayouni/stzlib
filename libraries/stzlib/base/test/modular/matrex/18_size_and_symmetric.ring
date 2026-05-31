# Narrative
# --------
# Size AND symmetric
#
# Extracted from stzmatrextest.ring, block #18.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{size(3x3) & property(symmetric)}")

aValid = [
	[1, 2, 3],
	[2, 4, 5],
	[3, 5, 6]
]

aWrongSize = [
	[1, 2],
	[2, 3]
]

aNotSymmetric = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aValid)
#--> TRUE

? oMx.Match(aWrongSize)
#--> FALSE

? oMx.Match(aNotSymmetric)
#--> FALSE

pf()
