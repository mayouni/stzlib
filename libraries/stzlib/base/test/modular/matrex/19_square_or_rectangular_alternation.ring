# Narrative
# --------
# Square OR rectangular (alternation)
#
# Extracted from stzmatrextest.ring, block #19.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{(shape(square) | shape(rectangular))}")

aSquare = [[1, 2], [3, 4]]
aRect = [[1, 2, 3], [4, 5, 6]]

? oMx.Match(aSquare)
#--> TRUE

? oMx.Match(aRect)
#--> TRUE

pf()
