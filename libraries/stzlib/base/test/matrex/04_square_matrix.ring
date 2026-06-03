# Narrative
# --------
# Square matrix
#
# Extracted from stzmatrextest.ring, block #4.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{shape(square)}")

aSquare = [[1, 2], [3, 4]]
aRect = [[1, 2, 3], [4, 5, 6]]

? oMx.Match(aSquare)
#--> TRUE

? oMx.Match(aRect)
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.24
