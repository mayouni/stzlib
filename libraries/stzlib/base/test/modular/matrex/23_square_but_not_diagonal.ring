# Narrative
# --------
# Square but NOT diagonal
#
# Extracted from stzmatrextest.ring, block #23.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{shape(square) & @!property(diagonal)}")

aDiagonal = [
	[1, 0, 0],
	[0, 2, 0],
	[0, 0, 3]
]

aFull = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aDiagonal)
#--> FALSE

? oMx.Match(aFull)
#--> TRUE

pf()

#=============================#
#  FINDING MATCHING MATRICES  #
#=============================#
