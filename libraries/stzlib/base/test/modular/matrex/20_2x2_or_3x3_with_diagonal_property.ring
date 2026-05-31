# Narrative
# --------
# 2x2 OR 3x3 with diagonal property
#
# Extracted from stzmatrextest.ring, block #20.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{(size(2x2) | size(3x3)) & property(diagonal)}")

aDiag2x2 = [
	[1, 0],
	[0, 2]
]

aDiag3x3 = [
	[1, 0, 0],
	[0, 2, 0],
	[0, 0, 3]
]

aDiag4x4 = [
	[1, 0, 0, 0],
	[0, 2, 0, 0],
	[0, 0, 3, 0],
	[0, 0, 0, 4]
]

? oMx.Match(aDiag2x2)
#--> TRUE

? oMx.Match(aDiag3x3)
#--> TRUE

? oMx.Match(aDiag4x4)
#--> FALSE

pf()

#============#
#  NEGATION  #
#============#
