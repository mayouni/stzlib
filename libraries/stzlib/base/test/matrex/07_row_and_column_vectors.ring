# Narrative
# --------
# Row and column vectors
#
# Extracted from stzmatrextest.ring, block #7.

load "../../stzBase.ring"


pr()

oMxRow = new stzMatrex("{shape(row)}")
oMxCol = new stzMatrex("{shape(column)}")

aRowVector = [[1, 2, 3, 4, 5]]
aColVector = [[1], [2], [3]]

? oMxRow.Match(aRowVector)
#--> TRUE

? oMxRow.Match(aColVector)
#--> FALSE

? oMxCol.Match(aColVector)
#--> TRUE

? oMxCol.Match(aRowVector)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24

#=====================#
#  PROPERTY MATCHING  #
#=====================#
