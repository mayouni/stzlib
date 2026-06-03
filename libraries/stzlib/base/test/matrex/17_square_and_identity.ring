# Narrative
# --------
# Square AND identity
#
# Extracted from stzmatrextest.ring, block #17.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{shape(square) & property(identity)}")

aIdentity3x3 = [
	[1, 0, 0],
	[0, 1, 0],
	[0, 0, 1]
]

aSquareNotIdentity = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aIdentity3x3)
#--> TRUE

? oMx.Match(aSquareNotIdentity)
#--> FALSE

pf()
