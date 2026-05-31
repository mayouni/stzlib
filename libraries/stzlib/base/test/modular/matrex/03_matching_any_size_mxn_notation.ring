# Narrative
# --------
# Matching any size (mxn notation)
#
# Extracted from stzmatrextest.ring, block #3.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{size(mxn)}")

aMatrix1 = [[1, 2], [3, 4]]
aMatrix2 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
aMatrix3 = [[1, 2, 3, 4]]

? oMx.Match(aMatrix1)
#--> TRUE

? oMx.Match(aMatrix2)
#--> TRUE

? oMx.Match(aMatrix3)
#--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.24

#==================#
#  SHAPE MATCHING  #
#==================#
