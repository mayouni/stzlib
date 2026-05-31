# Narrative
# --------
# Negating a pattern
#
# Extracted from stzmatrextest.ring, block #34.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(diagonal)}")
oMxNot = oMx.Not_()

aDiagonal = [[1, 0], [0, 2]]
aNonDiagonal = [[1, 2], [3, 4]]

? oMxNot.Match(aDiagonal)
#--> FALSE

? oMxNot.Match(aNonDiagonal)
#--> TRUE

pf()

#========================#
#  FILTERING OPERATIONS  #
#========================#
