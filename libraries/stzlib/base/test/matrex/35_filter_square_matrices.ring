# Narrative
# --------
# Filter square matrices
#
# Extracted from stzmatrextest.ring, block #35.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{shape(square)}")

aMatrices = [
	[[1, 2], [3, 4]],
	[[1, 2, 3], [4, 5, 6]],
	[[5, 6, 7], [8, 9, 10], [11, 12, 13]]
]

aFiltered = oMx.FilterMatrices(aMatrices)
? len(aFiltered)
#--> 2

pf()

#===================#
#  EXTRACTED PARTS  #
#===================#
