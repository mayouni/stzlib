# Narrative
# --------
# Get size from matched parts
#
# Extracted from stzmatrextest.ring, block #37.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{shape(square)}")

aMatrix = [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]]

oMx.Match(aMatrix)

? @@( oMx.Size() )
#--> [ 4, 4 ]

pf()
