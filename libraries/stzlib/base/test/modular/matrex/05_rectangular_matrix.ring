# Narrative
# --------
# Rectangular matrix
#
# Extracted from stzmatrextest.ring, block #5.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{shape(rectangular)}")

aSquare = [[1, 2], [3, 4]]
aRect = [[1, 2, 3], [4, 5, 6]]

? oMx.Match(aSquare)
#--> FALSE

? oMx.Match(aRect)
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.24
